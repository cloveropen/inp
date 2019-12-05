CREATE OR REPLACE FUNCTION clover_odr.inp_sch_admfee_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 通过住院号查询入院登记信息和费用明细列表 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 返回: 住院登记信息|费用明细列表

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码
	topcode clover_odr.adm_reg.opcode%type;  -- 操作员	
	
	tout_str_adm text := '';
	tout_str_fee text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	topcode := tin_arrays[3];
	
	--查询入院登记信息
	SELECT row_to_json(clover_odr.adm_reg.*) into tout_str_adm FROM clover_odr.adm_reg
		where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
	--查询费用明细
	SELECT json_agg(row_to_json(clover_odr.fee_detail.*)) into tout_str_fee FROM clover_odr.fee_detail 
	   where hsp_code=thsp_code and pid = tpid;
	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str_adm||'|'||tout_str_fee;
END;
$cloveropen$;