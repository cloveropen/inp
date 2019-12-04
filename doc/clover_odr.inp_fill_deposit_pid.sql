CREATE OR REPLACE FUNCTION clover_odr.inp_fill_deposit_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 用在院患者登记信息填写预交金金基本信息 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 先查询门急诊入院通知单,如果没有查询挂号记录
-- 患者办理入院必须至少有门诊挂号记录

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid_out%type; --门诊号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码
	topcode clover_odr.adm_reg.opcode%type;  
	tadm_reg clover_odr.adm_reg%rowtype;
	tdeposit clover_odr.deposit%rowtype;
	
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	topcode := tin_arrays[3];
	
	--查询在院患者表	
	SELECT * into tadm_reg FROM clover_odr.adm_reg
		where hsp_code=thsp_code and pid=tpid order by seq desc limit 1	;
	if coalesce(tadm_reg.seq,0)=0 then --没有在在院患者表中找到数据
		tdeposit.seq := 0;
		tdeposit.hsp_code :='';
		tdeposit.pid :='';
		tdeposit.ex_pid :='';
		tdeposit.patient_name :='';
		tdeposit.patient_type :='';
		tdeposit.in_type :='';
		tdeposit.dept_code :='';
		tdeposit.dept_code2 :='';
		tdeposit.room :='';
		tdeposit.bed_nmb :='';
		tdeposit.flow_nmb :='';
		tdeposit.invoice_nmb :='';
		tdeposit.apply_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
		tdeposit.apply_opcode :='';
		tdeposit.pay_status :='';
		tdeposit.pay_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
		tdeposit.opcode :='';
		tdeposit.bank :='';
		tdeposit.deposit_cancel :='0';
		tdeposit.pay_source :='';
		tdeposit.account :='';
		tdeposit.pay_sum := 0.00;
		tdeposit.pay_cash := 0.00;
		tdeposit.pay_weixin := 0.00;
		tdeposit.pay_alipay := 0.00;
		tdeposit.pay_union := 0.00;
		tdeposit.pay_chk := 0.00;
		tdeposit.pay_other := 0.00;
		tdeposit.remark := '';
		tdeposit.mch_ip := tip;
	else
	----------------------------------------入院患者表填写预交金信息beg-----------------------------------------------------------
		tdeposit.seq := 0;
		tdeposit.hsp_code := thsp_code;
		tdeposit.pid := tadm_reg.pid;
		tdeposit.ex_pid := tadm_reg.ex_pid;
		tdeposit.patient_name := tadm_reg.patient_name;
		tdeposit.patient_type := tadm_reg.patient_type;
		tdeposit.in_type := tadm_reg.in_type;
		tdeposit.dept_code := tadm_reg.dept_code;
		tdeposit.dept_code2 := tadm_reg.dept_code2;
		tdeposit.room := tadm_reg.room;
		tdeposit.bed_nmb := tadm_reg.bed_nmb;
		tdeposit.flow_nmb := '';
		tdeposit.invoice_nmb := '';
		tdeposit.apply_time := now();
		tdeposit.apply_opcode := topcode;
		tdeposit.pay_status := 'N';
		tdeposit.pay_time := null;
		tdeposit.opcode := '';
		tdeposit.bank := '';
		tdeposit.deposit_cancel :='0';
		tdeposit.pay_source := '住院处窗口';
		tdeposit.account := '';
		tdeposit.pay_sum := 0.00;
		tdeposit.pay_cash := 0.00;
		tdeposit.pay_weixin := 0.00;
		tdeposit.pay_alipay := 0.00;
		tdeposit.pay_union := 0.00;
		tdeposit.pay_chk := 0.00;
		tdeposit.pay_other := 0.00;
		tdeposit.remark := '';
		tdeposit.mch_ip	:= tip;
	----------------------------------------入院患者表填写预交金信息end-----------------------------------------------------------
    end if;	
	
	---------------------------------
	---返回json字符串数组
	SELECT row_to_json(tdeposit.*) into tout_str ;
	
    RETURN tout_str;
END;
$cloveropen$;