CREATE OR REPLACE FUNCTION clover_odr.inp_save_deposit(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 补预交金 入参:deposit(json格式) + "|" + topcode + "|" + tgc;
-- 过程如下:
--  1. 写入预交金记录表 状态为未支付
--	2. 写入预交金打印记录表 状态为未打印
--	3. 根据现金 微信 支付宝的不同调用支付接口，返回结果更新预交金记录表和预交金打印表，写入cash_set收费结算记录表
DECLARE
    tin_arrays text ARRAY;
	tdeposit clover_odr.deposit%rowtype;
	tdeposit_prn clover_odr.deposit_prn%rowtype;
	
	tdeposit_type clover_odr.json_deposit%rowtype;
	
	tjson_deposit_str text := '';
	topcode clover_odr.deposit.opcode%type;
	tchk_number boolean := false;
	tin_str1 text := '';
	tinvoice_nmb text := '';
	tflow_nmb text := '';
	
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tjson_deposit_str := tin_arrays[1];
	topcode := tin_arrays[2];
	
	select * from json_populate_record(null::clover_odr.json_deposit,tjson_deposit_str::json) into tdeposit_type;
	tdeposit.hsp_code := tdeposit_type.hsp_code;
	tdeposit.pid := tdeposit_type.pid;
	tdeposit.ex_pid := tdeposit_type.ex_pid;
	tdeposit.patient_name := tdeposit_type.patient_name;
	tdeposit.dept_code := tdeposit_type.dept_code;
	tdeposit.dept_code2 := tdeposit_type.dept_code2;
	tdeposit.room := tdeposit_type.room;
	tdeposit.bed_nmb := tdeposit_type.bed_nmb;
	tdeposit.bank := tdeposit_type.bank;
	tdeposit.pay_source := tdeposit_type.pay_source;
	tdeposit.account := tdeposit_type.account;
	tdeposit.remark := tdeposit_type.remark;
	tdeposit.patient_type := tdeposit_type.patient_type;
	tdeposit.in_type := tdeposit_type.in_type;
	tdeposit.apply_time := now();
	tdeposit.apply_opcode := topcode;
	tdeposit.pay_status := 'N';
	tdeposit.pay_time := null;
	tdeposit.opcode := '';
	tdeposit.deposit_cancel := '0';
	tdeposit.pay_sum := tdeposit_type.pay_sum;
	tdeposit.pay_cash := 0.00;
	tdeposit.pay_weixin := 0.00;
	tdeposit.pay_alipay := 0.00;
	tdeposit.pay_union := 0.00;
	tdeposit.pay_chk := 0.00;
	tdeposit.pay_other := 0.00;
	
	raise notice 'tdeposit.patient_name=%,tdeposit.pay_sum=%',tdeposit.patient_name,tdeposit.pay_sum;
	-- 检查姓名不能为空 入院科室必须存在,预交金金额可以为0,不能为非数字
	if coalesce(tdeposit.patient_name,'')='' then
		tout_str :=  '-`|患者姓名不能为空';
		return tout_str;
	end if;
	if coalesce(tdeposit.dept_code,'')='' then
		tout_str := '-1|患者住院科室不能为空';
		return tout_str;
	end if;
	select tdeposit.pay_sum::text  ~ '^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$' into tchk_number;
	if tchk_number=false then
		tout_str := '-1|预交金额非法,预交金额必须是大于等于0的数字';
		return tout_str;
	end if;	
	-- 生成预交金操作员流水号 预交金发票流水号
	SELECT to_char(to_number(coalesce(invoice_nmb3,'00000000'),'99999999')+1,'00000000') into tflow_nmb
	  FROM clover_md.kd99  where opcode=topcode;
	-- 获取打印门诊发票流水号(invoice_nmb2)
	select clover_odr.sch_invoice_nmb(topcode) into tin_str1;
	select split_part(tin_str1,'|', 3) into tinvoice_nmb;
	
	tdeposit.seq := nextval('clover_odr.seq_deposit');
	tdeposit.mch_ip := tip;
	tdeposit.flow_nmb := tflow_nmb;
	tdeposit.invoice_nmb := tinvoice_nmb;
	/*tdeposit.apply_time := now();
	tdeposit.apply_opcode := topcode;
	tdeposit.pay_status := 'N';
	tdeposit.pay_time := null;
	tdeposit.opcode := '';
	tdeposit.deposit_cancel := '0';
	tdeposit.pay_cash := 0.00;
	tdeposit.pay_weixin := 0.00;
	tdeposit.pay_alipay := 0.00;
	tdeposit.pay_union := 0.00;
	tdeposit.pay_chk := 0.00;
	tdeposit.pay_other := 0.00;
	*/
	insert into clover_odr.deposit values (tdeposit.*);
	
	--写入预交金打印表，状态是未打印
	tdeposit_prn.seq := nextval('clover_odr.seq_deposit_prn');
	tdeposit_prn.hsp_code := tdeposit.hsp_code;
	tdeposit_prn.pid := tdeposit.pid;
	tdeposit_prn.seq_deposit := tdeposit.seq;
	tdeposit_prn.patient_name := tdeposit.patient_name;
	tdeposit_prn.prn_status := 'N';
	tdeposit_prn.prn_time := null;
	tdeposit_prn.prn_opcode := '';
	tdeposit_prn.dept_code := tdeposit.dept_code;
	tdeposit_prn.dept_code2 := tdeposit.dept_code2;
	tdeposit_prn.room := tdeposit.room;
	tdeposit_prn.bed_nmb := tdeposit.bed_nmb;
	tdeposit_prn.flow_nmb := tdeposit.flow_nmb;
	tdeposit_prn.invoice_nmb := tdeposit.invoice_nmb;
	tdeposit_prn.pay_time := tdeposit.pay_time;
	tdeposit_prn.opcode := tdeposit.opcode;
	tdeposit_prn.bank := tdeposit.bank;
	tdeposit_prn.account := tdeposit.account;
	tdeposit_prn.pay_sum := tdeposit.pay_sum;
	tdeposit_prn.pay_cash := tdeposit.pay_cash;
	tdeposit_prn.pay_weixin := tdeposit.pay_weixin;
	tdeposit_prn.pay_alipay := tdeposit.pay_alipay;
	tdeposit_prn.pay_union := tdeposit.pay_union;
	tdeposit_prn.pay_chk := tdeposit.pay_chk;
	tdeposit_prn.pay_other := tdeposit.pay_other;
	insert into clover_odr.deposit_prn values (tdeposit_prn.*);
	
	tout_str := tdeposit.pid ||'|'||tinvoice_nmb;
	raise notice 'tout_str:%',tout_str;
    RETURN tout_str;
END;
$cloveropen$;