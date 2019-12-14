CREATE OR REPLACE FUNCTION clover_odr.inp_discharge_commit_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 在院患者出院结算 入参:tpid + "|" + thsp_code + "|" + middle_flag + "|" + out_mode + "|" + treate_result + "|" + out_dest + "|" + topcode + "|" + tgc;
-- 入参: 住院号|医院编号|是否中途结算|出院方式|治疗结果|出院去向|操作员|TGC
-- 过程如下:
--  1. 判断患者类别,如果是医保患者需要读卡后调用医保接口做预结算处理
--	2. 计算患者本次住院的总费用,预交金总额，根据医保接口(预结算记录表)计算出需要患者本次支付的部分
--	3. 患者本次结算应该返还金额 = 预交金总额 - 本次支付金额,不论以前交的是何种方式，都采用退现金方式。
--	4. 写入discharge 出院结算表
--	5. 计算费用分项,写入出院结算费用分项表discharge_fee
--	6. 如果是医保患者，写入出院结算医保信息明细表discharge_mi
--	7. 写入出院结算打印收据表discharge_prn 
--	8. 写入支付明细表cash_set 每次结算时支付方式、各项支付金额明细，(本次主要是退现金款)

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码	
	tdpre clover_odr.discharge_pre%rowtype;	
	td clover_odr.discharge%rowtype;
	tdprn clover_odr.discharge_prn%rowtype;
	tdfee clover_odr.discharge_fee%rowtype;  --出院费用分项表(按病案首页分类)
	
	tmiddle_flag text := '';  --是否中途结算
	tout_mode text := '';     --出院方式
	ttreate_result text := ''; --治疗结果
	tout_dest text := '';      --出院去向
	topcode text :='';
	tcash_set clover_odr.cash_set%rowtype;
	
	tin_str1 text :='';
	tout_str text := '';
	tout_str_prn text := '';
BEGIN		
	select string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	tmiddle_flag := tin_arrays[3];	
	tout_mode := tin_arrays[4];	
	ttreate_result := tin_arrays[5];	
	tout_dest := tin_arrays[6];
	topcode := tin_arrays[7];
	
	--从预结算记录表取最新一条预结算记录
	raise notice '从预结算记录表取最新一条预结算记录';
	SELECT * into tdpre	FROM clover_odr.discharge_pre 
	    where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
	--填写结算表结构
	raise notice '填写结算表结构';
	td.seq := nextval('clover_odr.seq_discharge');
	td.hsp_code := thsp_code;
	td.pid := tpid;
	SELECT ex_pid, patient_name,patient_type, in_type, idcard, health_id, micard, mi_company,mi_type, mi_pacc_left,
		in_time,diag_id, diag_name, diag_id2, diag_name2, diag_id3, diag_name3,dept_code, dept_code2,in_num
	INTO td.ex_pid, td.patient_name,td.patient_type,td.in_type,td.idcard,td.health_id,td.micard,td.mi_company,td.mi_type, td.mi_pacc_left,
		td.in_time,td.diag_id, td.diag_name, td.diag_id2, td.diag_name2, td.diag_id3, td.diag_name3,td.dept_code_out, td.dept_code_out2,td.in_num
	FROM clover_odr.adm_reg where hsp_code=thsp_code and pid=tpid;
	
	select clover_odr.sch_invoice_nmb(topcode,4) into tin_str1;
	select split_part(tin_str1,'|', 2) into td.invoice_nmb;
	SELECT to_char(to_number(coalesce(invoice_nmb4,'00000000'),'99999999')+1,'00000000') into td.flow_nmb
	  FROM clover_md.kd99  where opcode=topcode;
	
	td.out_time := now();
	td.settle_time := now();
	td.opcode := topcode;
	td.middle_flag := tmiddle_flag;
	td.out_mode := tout_mode;
	td.treate_result := ttreate_result;
	td.out_dest := tout_dest;
	td.cancel_flag := '0';
	-- 计算总费用
	raise notice '计算总费用';
	SELECT coalesce(sum(real_price*quantity*days),0.00) into td.all_sum FROM clover_odr.fee_detail 
	    where hsp_code=thsp_code and pid=tpid;
	-- 从预结算记录表计算现金 统筹 个人帐户 农合统筹 商业保险支付
	raise notice '从预结算记录表计算现金 统筹 个人帐户 农合统筹 商业保险支付';
	SELECT cash_mi, pacc_mi, fund_mi+large_mi+gyw_mi+low_mi
		into td.cash_sum, td.pacc_sum, td.fund_sum
	FROM clover_odr.discharge_pre where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
	td.fund_nh_sum := 0.00;
	td.fund_commeric := 0.00;
	--从预交金表计算预交现金 预交支票 预交微信 预交支付宝 预交银联
	raise notice '从预交金表计算预交现金 预交支票 预交微信 预交支付宝 预交银联';
	SELECT coalesce(sum(pay_cash),0.00), coalesce(sum(pay_weixin),0.00), coalesce(sum(pay_alipay),0.00), 
		coalesce(sum(pay_union),0.00), coalesce(sum(pay_chk),0.00),coalesce(sum(pay_other),0.00),coalesce(sum(pay_voucher),0.00)
	INTO td.pre_cash,td.pre_weixin,td.pre_alipay, 
		td.pre_union, td.pre_check,td.pre_other,td.pre_voucher
	FROM clover_odr.deposit where hsp_code=thsp_code and pid=tpid and pay_status<>'N';
	    
	 -- 计算返回现金，其余返回为0
	 raise notice '计算返回现金，其余返回为0';
	 td.change_cash := td.pre_cash + td.pre_weixin + td.pre_alipay + td.pre_union + td.pre_check + td.pre_other + td.pre_voucher - td.cash_sum;
	 td.change_check := 0.00;
	 td.change_weixin := 0.00;
	 td.change_alipay := 0.00;
	 td.change_union := 0.00;
	
	--计算住院天数
	raise notice '计算住院天数';
	td.indays := date_part('day',td.in_time - now());
	raise notice '写入discharge';
	insert into clover_odr.discharge values (td.*);
	
	--填写预结算打印表结构
	raise notice '填写预结算打印表结构';
	tdprn.seq := nextval('clover_odr.seq_discharge_prn');
	tdprn.seq_discharge := td.seq;
	tdprn.hsp_code := thsp_code;
	tdprn.pid := tpid;
	tdprn.patient_name := td.patient_name;
	tdprn.prn_status := 'N';
	tdprn.opcode :=topcode;
	tdprn.prn_time := now();
	tdprn.all_sum := td.all_sum;
	-- 计算分项，按医保分类
	raise notice '计算分项，按医保分类';
	--"11"	"西药" s01	
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s01 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='11';
	--"12"	"中成药" s02
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s02 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='12';
	--"13"	"中草药" s03
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s03 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='13';
	--"21"	"X 光" s04
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s04 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='21';
	--"22"	"化验费" s05
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s05 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='22';
	--"23"	"检查费" s06
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s06 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='23';
	--"24"	"超声费" s07
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s07 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='24';
	--"25"	"CT费" s08
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s08 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='25';
	--"26"	"磁共振" s09
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s09 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='26';
	--"27"	"处置费" s10
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s10 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='27';
	--"28"	"治疗费" s11
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s11 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='28';
	--"29"	"诊疗费" s12
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s12 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='29';
	--"30"	"护理费" s13
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s13 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='30';
	--"31"	"手术费" s14
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s14 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='31';
	--"32"	"卫材费" s15
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s15 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='32';
	--"33"	"麻醉费" s16
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s16 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='33';
	--"34"	"输血费" s17
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s17 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='34';
	--"35"	"输氧费" s18
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s18 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='35';
	--"36"	"监护费" s19
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s19 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='36';
	--"41"	"床位费" s20
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s20 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='41';
	--"42"	"取暖费" s21
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s21 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='42';
	--"50"	"其他费用" s22
	SELECT coalesce(sum(real_price*quantity*days),0.00) into tdprn.s22 FROM clover_odr.fee_detail 
		where hsp_code=thsp_code and pid=tpid and presc_status<>'9' and item_class='50';
	tdprn.s23 := 0.00;
	tdprn.s24 := 0.00;
	tdprn.s25 := 0.00;
	tdprn.s26 := 0.00;
	tdprn.s27 := 0.00;
	tdprn.s28 := 0.00;
	tdprn.s29 := 0.00;
	tdprn.s30 := 0.00;
	raise notice '写入t_discharge_prn';
	insert into clover_odr.discharge_prn values (tdprn.*);
	
	--写入出院结算费用分项表discharge_fee
	tdfee.seq := nextval('seq_discharge_fee');
	tdfee.hsp_code := thsp_code;
	tdfee.seq_discharge := td.seq;
	tdfee.pid := tpid;
	tdfee.ex_pid := td.ex_pid;
	tdfee.patient_name := td.patient_name;
	tdfee.trade_type := '0';
	tdfee.settle_time := td.settle_time;
	tdfee.opcode := topcode; 
	tdfee.all_sum := td.all_sum;
	tdfee.all_sum_upper := clover_md.udf_digits2hanzi(trunc(td.all_sum):: bigint)||'元'||
	    clover_md.udf_digits2hanzi(((trunc(td.all_sum,1) - trunc(td.all_sum))*10 ):: bigint)||'角'||
	    clover_md.udf_digits2hanzi(((trunc(td.all_sum,2) - trunc(td.all_sum,1))*100 ):: bigint)||'分';
	-- "11"	"综合医疗服务" sum01,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum01
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='11';
    -- "12"	"一般检查治疗"  sum02,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum02
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='12';
	-- "13"	"社区卫生服务及预防保健" sum03, 
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum03
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='13';
	-- "14"	"其他医疗服务项目" sum04,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum04
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='14';
	-- "21"	"医学影像" sum05,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum05
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='21';
	-- "22"	"超声检查" sum06,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum06
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='22';
	-- "23"	"核医学" sum07,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum07
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='23';
	-- "24"	"放射治疗" sum08,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum08
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='24';
	-- "25"	"检验" sum09,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum09
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='25';
	-- "26"	"血型与配血" sum10,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum10
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='26';
	-- "27"	"病理检查" sum11,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum11
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='27';
	-- "31"	"临床各系统诊疗" sum12,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum12
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='31';
	-- "32"	"经血管介入诊疗" sum13,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum13
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='32';
	-- "33"	"手术治疗" sum14,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum14
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='33';
	-- "34"	"物理治疗与康复" sum15,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum15
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='34';
	-- "41"	"中医外治" sum16,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum16
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='41';
	-- "42"	"中医骨伤" sum17,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum17
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='42';
	-- "43"	"针刺" sum18,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum18
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='43';
	-- "44"	"炙法" sum19,
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum19
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='44';
	-- "45"	"推拿疗法" sum20
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum20
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='45';
	-- "46"	"中医肛肠" sum21
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum21
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='46';
	-- "47"	"中医特殊疗法" sum22
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum22
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='47';
	-- "48"	"中医综合" sum23
	SELECT coalesce(sum(f.real_price*f.quantity*f.days),0.00) INTO tdfee.sum23
	    FROM clover_odr.fee_detail f, clover_md.dict_item d 
	    where f.item_code=d.item_code and f.hsp_code=thsp_code and f.pid=tpid
	    and left(d.fee_type,2)='48';
	tdfee.sum24 := 0.00;
	tdfee.sum25 := 0.00;
	tdfee.sum26 := 0.00;
	tdfee.sum27 := 0.00;
	tdfee.sum28 := 0.00;
	tdfee.sum29 := 0.00;
	tdfee.sum30 := 0.00;
	
	insert into clover_odr.discharge_fee values (tdfee.*);
	
	-- 写入支付明细表cash_set 每次结算时支付方式、各项支付金额明细，(本次主要是退现金款)
	tcash_set.seq := nextval('clover_odr.seq_cash_set');
	tcash_set.hsp_code := thsp_code;
	tcash_set.pid := tpid;
	tcash_set.patient_name := td.patient_name;
	tcash_set.patient_type := td.patient_type;
	tcash_set.pay_cate := 'discharge';
	tcash_set.invoice_nmb := td.invoice_nmb;
	tcash_set.flow_nmb := td.flow_nmb;
	tcash_set.pay_time := td.settle_time;
	tcash_set.opcode := topcode;
	tcash_set.trade_type := '0';
	tcash_set.pay_type := '出院结算窗口'; --支付渠道
	tcash_set.pay_str := tdpre.mi_set_str;
	tcash_set.all_sum := td.all_sum;
	tcash_set.cash_sum := td.cash_sum;
	tcash_set.pacc_sum := td.pacc_sum;
	tcash_set.fund_sum := td.fund_sum;
	tcash_set.fund_nh_sum := td.fund_nh_sum;
	tcash_set.fund_commeric := td.fund_commeric;
	tcash_set.weixin_sum := 0.00;
	tcash_set.alipay_sum := 0.00;
	tcash_set.unionpay_sum := 0.00;
	tcash_set.check_sum := 0.00;
	tcash_set.voucher_sum := 0.00;
	tcash_set.spec_sum := 0.00;

	insert into clover_odr.cash_set values (tcash_set.*);
	-- 转入院登记信息为住院登记信息
	INSERT INTO clover_odr.adm_reg_his select * from clover_odr.adm_reg where hsp_code=thsp_code and pid=tpid;
	DELETE FROM clover_odr.adm_reg
	    WHERE hsp_code=thsp_code and pid=tpid;
	-- 转在院费用明细为出院费用明细
	INSERT INTO clover_odr.fee_detail_his select * from clover_odr.fee_detail where hsp_code=thsp_code and pid=tpid;
	DELETE FROM clover_odr.fee_detail
	    WHERE hsp_code=thsp_code and pid=tpid;
	-- 转在院预交金表为出院预交金表
	INSERT INTO clover_odr.deposit_his select * from clover_odr.deposit where hsp_code=thsp_code and pid=tpid;
	DELETE FROM clover_odr.deposit
	    WHERE hsp_code=thsp_code and pid=tpid;
	-- 转在院医嘱为出院医嘱
	
	-- 转在院处方表为出院处方表
	
	-- 转在院图片为出院图片表
	INSERT INTO clover_odr.adm_reg_pic_his select * from clover_odr.adm_reg_pic where hsp_code=thsp_code and pid=tpid;
	DELETE FROM clover_odr.adm_reg_pic
	    WHERE hsp_code=thsp_code and pid=tpid;
	--返回json数据
	raise notice '返回json数据';
	SELECT json_agg(row_to_json(td.*)) into tout_str ;	
	SELECT json_agg(row_to_json(tdprn.*)) into tout_str_prn ;	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str||'|'||tout_str_prn;
END;
$cloveropen$;