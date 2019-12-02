CREATE OR REPLACE FUNCTION clover_odr.inp_save_admreg(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 通过门诊号查询填充入院登记信息 入参:adm_reg(json格式) + "|" + adm_reg_pic(json格式) + "|" + topcode + "|" + tgc;
-- 入院登记过程:
--  1. 检查必须的字段，预交金必须为数字>=0
--	2. 用存储过程写入adm_reg,adm_reg_pic,如果预交金金额大于0，写入预交金表，状态为未支付。
--	3. 删除入院通知单表，转到入院通知单历史表
--	4. 如果是现金，直接写入cash_set表。如果是微信或支付宝，调用接口，成功后写入cash_set表，更新预交金表状态和支付类别
--	5. 如果是医保患者，调用医保接口，成功后返回更新医保登记信息串和读卡信息串

DECLARE
    tin_arrays text ARRAY;
	tadm_reg clover_odr.adm_reg%rowtype;
	-- tadm_reg_pic clover_odr.admin_reg_pic%rowtype;
	tdeposit clover_odr.deposit%rowtype;
	tempi clover_md.empi%rowtype;
	tdeposit_prn clover_odr.deposit_prn%rowtype;
	
	tjson_adm_reg text := '';
	tjson_adm_reg_pic text := '';
	
	tchk_number boolean := false;
	--tpid clover_odr.adm_reg.pid%type; 
	
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tjson_adm_reg := tin_arrays[1];
	-- tjson_adm_reg_pic := tin_arrays[2];	
	
	select * from json_populate_record(null::clover_odr.adm_reg,tjson_adm_reg::json) into tadm_reg;
	-- select * from json_populate_record(null::clover_odr.admin_reg_pic,tjson_adm_reg_pic::json) into tadm_reg_pic;
	raise notice 'adm_reg.patient_name=%,tadm_reg.hsp_code=%',tadm_reg.patient_name,tadm_reg.hsp_code;
	-- 检查姓名不能为空 入院科室必须存在,预交金金额可以为0,不能为非数字
	if coalesce(tadm_reg.patient_name,'')='' then
		tout_str :=  '-`|患者姓名不能为空';
		return tout_str;
	end if;
	if coalesce(tadm_reg.dept_code,'')='' then
		tout_str := '-1|患者住院科室不能为空';
		return tout_str;
	end if;
	select tadm_reg.pre_pay_sum::text  ~ '^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$' into tchk_number;
	if tchk_number=false then
		tout_str := '-1|预交金额非法,预交金额必须是大于等于0的数字';
		return tout_str;
	end if;	
	-- 生成住院号，获取患者主索引，计算在本院住院次数，住院号格式为患者主索引+两位住院次数
	if length(trim(coalesce(tadm_reg.ex_pid,'')))>6 then
       SELECT coalesce(num_in,0)+1 into tempi.num_in FROM clover_md.empi where patient_id=tadm_reg.ex_pid;
       tadm_reg.pid := tadm_reg.ex_pid||trim(to_char(tempi.num_in,'00'));
       UPDATE clover_md.empi
		SET patient_name=tadm_reg.patient_name,
		gender=coalesce(tadm_reg.gender,gender), 
		idcard=coalesce(tadm_reg.idcard,idcard), 
		micard=coalesce(tadm_reg.micard,micard),
		mi_type=coalesce(tadm_reg.mi_type,mi_type), 
		employer_org_name=coalesce(tadm_reg.mi_company,employer_org_name), 
		addr_prov=coalesce(tadm_reg.addr_prov,addr_prov), 
		addr_city=coalesce(tadm_reg.addr_city,addr_city), 
		addr_county=coalesce(tadm_reg.addr_county,addr_county), 
		addr_township=coalesce(tadm_reg.addr_township,addr_township), 
		addr_street=coalesce(tadm_reg.addr_street,addr_street), 
		addr_house_nmb=coalesce(tadm_reg.addr_house_nmb,addr_house_nmb),
		sources='入院登记窗口更新',
		up_time=now(),
		up_person=tadm_reg.opcode, 
		num_in=tempi.num_in
	WHERE patient_id = tadm_reg.ex_pid;
    -----------------------------新患者,需要建立主索引档案------------------------------------------------
    else
       select trim(to_char(nextval('clover_odr.pid'),'000000000')) into tadm_reg.ex_pid;
       tadm_reg.pid := tadm_reg.ex_pid||'01';
       --  建立新的患者主索引记录
       tempi.patient_id := tadm_reg.ex_pid;
       tempi.patient_name := tadm_reg.patient_name;
       tempi.match_type := '符合';
       tempi.gender := tadm_reg.gender;
       tempi.idcard := tadm_reg.idcard;
       tempi.micard := tadm_reg.micard;
       tempi.mi_type := tadm_reg.mi_type;
       tempi.employer_org_name := tadm_reg.mi_company;
	   tempi.addr_prov := tadm_reg.addr_prov;
       tempi.addr_city := tadm_reg.addr_city;
       tempi.addr_county := tadm_reg.addr_county;
       tempi.addr_township := tadm_reg.addr_township;
       tempi.addr_street := tadm_reg.addr_street;
       tempi.addr_house_nmb := tadm_reg.addr_house_nmb;
       tempi.sources := '入院登记窗口新增';
       tempi.status := '有效';
       tempi.create_org := tadm_reg.hsp_code;
       tempi.create_time := now();
       tempi.create_person := tadm_reg.reg_opcode; 
       tempi.num_out :=0;
       tempi.num_in := 1;

       insert into clover_md.empi values (tempi.*);
    end if;
	-- 填充adm_reg_pic里面的必要字段
	-- tadm_reg_pic.seq := nextval('clover_odr.seq_admin_reg_pic');
	-- tadm_reg_pic.hsp_code := tadm_reg.hsp_code;
	-- tadm_reg_pic.pid := tadm_reg.pid;
	-- tadm_reg_pic.ex_pid := tadm_reg.ex_pid;
	-- tadm_reg_pic.patient_name := tadm_reg.patient_name;
	-- tadm_reg_pic.idcard := tadm_reg.idcard;
	-- tadm_reg_pic.health_id := tadm_reg.health_id;
	-- tadm_reg_pic.micard := tadm_reg.micard;
	-- tadm_reg_pic.capture_time := now();
	-- tadm_reg_pic.capture_opid := tadm_reg.opcode;
	-- tadm_reg_pic.mch_ip := tip;
	-- 保存admin_reg
	tadm_reg.seq := nextval('clover_odr.seq_adm_reg');
	tadm_reg.mch_ip := tip;
	insert into clover_odr.adm_reg values (tadm_reg.*);
	-- 保存adin_reg_pic
	-- insert into clover_odr.adm_reg_pic values (tadm_reg_pic.*);
	-- 如果预交金额>0 写入预交金表，状态是未支付
	if tadm_reg.pre_pay_sum>0 then	    
		tdeposit.seq := nextval('clover_odr.seq_deposit');
		tdeposit.hsp_code := tadm_reg.hsp_code;
		tdeposit.pid := tadm_reg.pid;
		tdeposit.ex_pid := tadm_reg.ex_pid;
		tdeposit.patient_name := tadm_reg.patient_name;
		tdeposit.dept_code := tadm_reg.dept_code;
		tdeposit.dept_code2 := tadm_reg.dept_code2;
		tdeposit.room := tadm_reg.room;
		tdeposit.bed_nmb := tadm_reg.bed_nmb;
		tdeposit.flow_nmb := '';
		tdeposit.invoice_nmb := '';
		tdeposit.apply_time := now();
		tdeposit.apply_opcode := tadm_reg.opcode;
		tdeposit.pay_status := 'N';
		tdeposit.pay_time := null;
		tdeposit.opcode := '';
		tdeposit.bank := '';
		tdeposit.deposit_cancel :='0';
		tdeposit.pay_source := '';
		tdeposit.account := '';
		tdeposit.pay_sum := tadm_reg.pre_pay_sum;
		tdeposit.pay_cash := 0.00;
		tdeposit.pay_weixin := 0.00;
		tdeposit.pay_alipay := 0.00;
		tdeposit.pay_union := 0.00;
		tdeposit.pay_chk := 0.00;
		tdeposit.pay_other := 0.00;
		tdeposit.remark := '';
		tdeposit.mch_ip := tip;
		
		insert into clover_odr.deposit values (tdeposit.*);
		-- 写入预交金打印表，状态是未打印
		tdeposit_prn.seq := nextval('clover_odr.seq_deposit_prn');
		tdeposit_prn.hsp_code := tdeposit.hsp_code;
		tdeposit_prn.pid := tdeposit.pid;
		tdeposit_prn.seq_deposit := tdeposit.seq;
		tdeposit_prn.patient_name := tdeposit.patient_name;
		tdeposit_prn.prn_status := '0';
		tdeposit_prn.prn_time := null;
		tdeposit_prn.prn_opcode := '';
		tdeposit_prn.dept_code := tdeposit.dept_code;
		tdeposit_prn.dept_code2 := tdeposit.dept_code2;
		tdeposit_prn.room := tdeposit.room;
		tdeposit_prn.bed_nmb := tdeposit.bed_nmb;
		tdeposit_prn.flow_nmb := tdeposit.flow_nmb;
		tdeposit_prn.invoice_nmb := tdeposit.invoice_nmb;
		tdeposit_prn.pay_time := null;
		tdeposit_prn.opcode := '';
		tdeposit_prn.bank := '';
		tdeposit_prn.account := '';
		tdeposit_prn.pay_sum := tdeposit.pay_sum;
		tdeposit_prn.pay_cash := tdeposit.pay_cash;
		tdeposit_prn.pay_weixin := tdeposit.pay_weixin;
		tdeposit_prn.pay_alipay := tdeposit.pay_alipay;
		tdeposit_prn.pay_union := tdeposit.pay_union;
		tdeposit_prn.pay_chk := tdeposit.pay_chk;
		tdeposit_prn.pay_other := tdeposit.pay_other;
		insert into clover_odr.deposit_prn values (tdeposit_prn.*);	
	
	end if;
	-- 删除入院入院通知单表，转到历史表
	INSERT INTO clover_odr.pat_retain_his select * from clover_odr.pat_retain where pid = tadm_reg.pid_out;
    delete from clover_odr.pat_retain where pid = tadm_reg.pid_out;
	
	--判断支付类别，如果是现金支付直接写入cash_set,其他支付调用另外的函数
	
	tout_str := tadm_reg.pid ||'|ok';
	raise notice 'tout_str:%',tout_str;
    RETURN tout_str;
END;
$cloveropen$;