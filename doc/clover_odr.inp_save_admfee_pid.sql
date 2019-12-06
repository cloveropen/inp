CREATE OR REPLACE FUNCTION clover_odr.inp_save_admfee_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 补记住院费用明细 入参:tpid + "|" + titem_code + "|" + titem_num + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 返回: 住院号|费用总额

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	titem_code clover_odr.fee_detail.item_code%type;
	titem_num clover_odr.fee_detail.quantity%type;
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码
	topcode clover_odr.adm_reg.opcode%type;  -- 操作员	
	tall_sum clover_odr.adm_reg.all_sum%type;
	
	tadm_reg clover_odr.adm_reg%rowtype;
	tfee_detail clover_odr.fee_detail%rowtype;
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	titem_code := tin_arrays[2];
	titem_num := CAST(coalesce(tin_arrays[3], '1') AS integer) ;
	thsp_code := tin_arrays[4];	
	topcode := tin_arrays[5];
	
	--查询入院登记信息
	SELECT * into tadm_reg FROM clover_odr.adm_reg
		where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
    -- 查询项目编码对应的诊疗项目名称 单价 类别 ...
	SELECT item_name, unit, ref_price, real_price,  mi_type,  mi_code, mi_degree, dept_code
	    into tfee_detail.item_name,tfee_detail.units,tfee_detail.ref_price, tfee_detail.real_price,
		 tfee_detail.item_class, tfee_detail.mi_code, tfee_detail.mi_degree, tfee_detail.exec_dept
	    FROM clover_md.dict_item where item_code=titem_code and hospital_code=thsp_code;
	
	tfee_detail.seq := nextval('clover_odr.seq_fee_detail');
	tfee_detail.hsp_code := thsp_code;
	tfee_detail.pid_type := 'I';
	tfee_detail.pid := tpid;
	tfee_detail.ex_pid := tadm_reg.ex_pid;
	tfee_detail.patient_name := tadm_reg.patient_name;
	tfee_detail.patient_type := tadm_reg.patient_type;
	tfee_detail.reg_type := tadm_reg.in_type;
	tfee_detail.dept_code := tadm_reg.dept_code;
	tfee_detail.doctor_code := tadm_reg.doctor_in_charge;
	tfee_detail.item_code := titem_code;
	tfee_detail.quantity := titem_num;
	tfee_detail.days := 1;
	tfee_detail.drug_pkey := '';
	tfee_detail.cal_time := now();
	tfee_detail.cal_opcode := topcode;
	tfee_detail.cashtime := now();
	tfee_detail.cash_opcode := topcode;
	tfee_detail.exec_time := null;
	tfee_detail.exec_opcode := '';
	tfee_detail.presc_status := '1';
	tfee_detail.invoice_nmb :='';
	tfee_detail.flow_nmb :='';
	tfee_detail.presc_nmb := topcode||'-'||trim(to_char(tfee_detail.seq,'999999999999'));
	tfee_detail.receipt_nmb :='';
	tfee_detail.item_sum := tfee_detail.real_price*tfee_detail.quantity*tfee_detail.days;
	tfee_detail.cancel_flag :='0';
	
	insert into clover_odr.fee_detail values (tfee_detail.*);
	--计算补记费用后的总费用
	SELECT coalesce(sum(real_price*quantity*days),0) into tall_sum
	    FROM clover_odr.fee_detail where pid=tpid and hsp_code=thsp_code;
	---------------------------------
	---返回结果 住院号|费用总额
	
    RETURN tpid||'|'||trim(to_char(tall_sum,'99999999990.00'));
END;
$cloveropen$;