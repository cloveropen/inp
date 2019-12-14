CREATE OR REPLACE FUNCTION clover_odr.inp_admreg_regout(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 出院登记 入参:pid + "|" + thsp_code+"|"+tmiddle_flag+"|"+ out_mode + "|" + treate_result + "|" + out_dest + "|" + topcode + "|" + tgc;
-- 出院登记过程:
--  1. 更新入院登记表状态为出院登记状态,in_cancel如果不等于Y，说明不是取消入院状态，更新为REGOUT
--  2. 写入出院登记表adm_reg_chkout

DECLARE
    tin_arrays text ARRAY;
	tadm_reg clover_odr.adm_reg%rowtype;
	tpid adm_reg.pid%type;
	thsp_code adm_reg.hsp_code%type;
	topcode adm_reg.opcode%type;
	tadm_reg_chkout clover_odr.adm_reg_chkout%rowtype;
	tmiddle_flag text := '0';
	tout_mode text := '';
	ttreate_result text := '';
	tout_dest text := '';
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	tmiddle_flag := tin_arrays[3];	
	tout_mode := tin_arrays[4];
	ttreate_result := tin_arrays[5];
	tout_dest := tin_arrays[6];
	topcode := tin_arrays[7];
	-- 判断入院登记信息是否取消，如果取消提示出错返回
	SELECT * into tadm_reg FROM clover_odr.adm_reg 
	    where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
	if coalesce(tadm_reg.in_cancel,'0')='N' then
	    raise notice '';
		tout_str := '-1';
		return tout_str;
	end if;
	--更新入院登记表状态为院登记状态
	UPDATE clover_odr.adm_reg
	    SET  in_cancel='REGOUT'
	    WHERE hsp_code=thsp_code and pid=tpid;
	-- 写入出院登记表adm_reg_chkout
	tadm_reg_chkout.seq := nextval('clover_odr.seq_adm_reg_chkout');
	tadm_reg_chkout.hsp_code := thsp_code;
	tadm_reg_chkout.pid := tpid;
	tadm_reg_chkout.ex_pid := tadm_reg.ex_pid;
	tadm_reg_chkout.patient_name := tadm_reg.patient_name;
	tadm_reg_chkout.in_num := tadm_reg.in_num;
	tadm_reg_chkout.all_sum := tadm_reg.all_sum;
	tadm_reg_chkout.pre_pay_sum := tadm_reg.pre_pay_sum;
	tadm_reg_chkout.pre_pay_left := tadm_reg.pre_pay_left;
	tadm_reg_chkout.pre_reg_flag := tadm_reg.pre_reg_flag;
	tadm_reg_chkout.diag_id := tadm_reg.diag_id;
	tadm_reg_chkout.diag_name := tadm_reg.diag_name;
	tadm_reg_chkout.diag_id2 := tadm_reg.diag_id2;
	tadm_reg_chkout.diag_name2 := tadm_reg.diag_name2;
	tadm_reg_chkout.diag_id3 := tadm_reg.diag_id3;
	tadm_reg_chkout.diag_name3 := tadm_reg.diag_name3;
	tadm_reg_chkout.middle_flag := tmiddle_flag;
	tadm_reg_chkout.dept_code_out := tadm_reg.dept_code;
	tadm_reg_chkout.dept_code_out2 := tadm_reg.dept_code2;
	tadm_reg_chkout.out_mode := tout_mode;
	tadm_reg_chkout.treate_result := ttreate_result;
	tadm_reg_chkout.out_dest := tout_dest;
	tadm_reg_chkout.chkout_time := now();
	tadm_reg_chkout.chkout_opcode := topcode;
	tadm_reg_chkout.cancel_flag := '0';
	tadm_reg_chkout.cancel_time := null;
	tadm_reg_chkout.cancel_opcode := '';
	tadm_reg_chkout.cancel_reason :='';
	
    insert into clover_odr.adm_reg_chkout values (tadm_reg_chkout.*);
	
	tout_str := tadm_reg.pid ;
	raise notice 'tout_str:%',tout_str;
    RETURN tout_str;
END;
$cloveropen$;