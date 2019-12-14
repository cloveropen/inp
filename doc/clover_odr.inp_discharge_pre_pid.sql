CREATE OR REPLACE FUNCTION clover_odr.inp_discharge_pre_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 在院患者预结算 入参:tpid + "|" + thsp_code + "|" + middle_flag + "|" + out_mode + "|" + treate_result + "|" + out_dest + "|" + topcode + "|" + tgc;
-- 入参: 住院号|医院编号|是否中途结算|出院方式|治疗结果|出院去向|操作员|TGC
-- 返回: 预结算结果json

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码	
	tdpre clover_odr.discharge_pre%rowtype;	
	td clover_odr.discharge%rowtype;
	tdprn clover_odr.discharge_prn%rowtype;
	
	tmiddle_flag text := '';  --是否中途结算
	tout_mode text := '';     --出院方式
	ttreate_result text := ''; --治疗结果
	tout_dest text := '';      --出院去向
	topcode text :='';
	
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
	
	execute 'DROP TABLE IF EXISTS t_discharge,t_discharge_prn';
    execute 'CREATE TEMP TABLE t_discharge as select * from clover_odr.discharge with no data';
	execute 'CREATE TEMP TABLE t_discharge_prn as select * from clover_odr.discharge_prn with no data';
	
	--从预结算记录表取最新一条预结算记录
	raise notice '从预结算记录表取最新一条预结算记录';
	SELECT * into tdpre	FROM clover_odr.discharge_pre 
	    where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
	--填写预结算表结构
	raise notice '填写预结算表结构';
	td.seq := 0;
	td.hsp_code := thsp_code;
	td.pid := tpid;
	SELECT ex_pid, patient_name,patient_type, in_type, idcard, health_id, micard, mi_company,mi_type, mi_pacc_left,
		in_time,diag_id, diag_name, diag_id2, diag_name2, diag_id3, diag_name3,dept_code, dept_code2,in_num
	INTO td.ex_pid, td.patient_name,td.patient_type,td.in_type,td.idcard,td.health_id,td.micard,td.mi_company,td.mi_type, td.mi_pacc_left,
		td.in_time,td.diag_id, td.diag_name, td.diag_id2, td.diag_name2, td.diag_id3, td.diag_name3,td.dept_code_out, td.dept_code_out2,td.in_num
	FROM clover_odr.adm_reg where hsp_code=thsp_code and pid=tpid;
	
	td.invoice_nmb := '';
	td.flow_nmb := '';
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
	raise notice '写入t_discharge';
	insert into t_discharge values (td.*);
	
	--填写预结算打印表结构
	raise notice '填写预结算打印表结构';
	tdprn.seq := 0;
	tdprn.seq_discharge := 0;
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
	insert into t_discharge_prn values (tdprn.*);
	--返回json数据
	raise notice '返回json数据';
	SELECT json_agg(row_to_json(t_discharge.*)) into tout_str FROM t_discharge;	
	SELECT json_agg(row_to_json(t_discharge_prn.*)) into tout_str_prn FROM t_discharge_prn;	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str||'|'||tout_str_prn;
END;
$cloveropen$;