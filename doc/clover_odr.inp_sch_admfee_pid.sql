CREATE OR REPLACE FUNCTION clover_odr.inp_sch_admfee_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$END;
$cloveropen$;
-- 通过住院号查询入院登记信息和费用明细列表 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 返回: 住院登记信息|费用明细列表

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码
	topcode clover_odr.adm_reg.opcode%type;  -- 操作员	
	
	tprov text := '';
	tcity text := '';
	tcounty text := '';
	ttown text := '';
	
	tadm_reg clover_odr.adm_reg%rowtype;
	tout_str_adm text := '';
	tout_str_fee text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	topcode := tin_arrays[3];
	
	--查询入院登记信息
	SELECT * into tadm_reg FROM clover_odr.adm_reg
		where hsp_code=thsp_code and pid=tpid order by seq desc limit 1;
    -- 转换就诊类别in_type 患者类别patient_type 住址addr_street=汉字的省市区县详细地址
	begin
	    SELECT term_name into tadm_reg.in_type FROM clover_md.dict_health_term
	        where class_id='in_type' and term_id=tadm_reg.in_type;
	    SELECT term_name into tadm_reg.patient_type FROM clover_md.dict_health_term
	        where class_id='per_cate' and term_id=tadm_reg.patient_type; 
	end;
	begin
		SELECT name into tprov FROM clover_md.dict_addr_prov where province_id=tadm_reg.addr_prov;
		tadm_reg.addr_street := tprov;
		SELECT name into tcity FROM clover_md.dict_addr_city where city_id=tadm_reg.addr_city;
		tadm_reg.addr_street := tadm_reg.addr_street||tcity;
		SELECT name into tcounty FROM clover_md.dict_addr_county where country_id=tadm_reg.addr_county;
		tadm_reg.addr_street := tadm_reg.addr_street||tcounty;
		SELECT name into ttown FROM clover_md.dict_addr_street where town_id=tadm_reg.addr_township;
		tadm_reg.addr_street := tadm_reg.addr_street||ttown;
	end;
	tadm_reg.addr_street := tadm_reg.addr_street||coalesce(tadm_reg.addr_house_nmb,'');
	SELECT row_to_json(tadm_reg.*) into tout_str_adm ;
	--查询费用明细
	SELECT json_agg(row_to_json(clover_odr.fee_detail.*)) into tout_str_fee FROM clover_odr.fee_detail 
	   where hsp_code=thsp_code and pid = tpid;
	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str_adm||'|'||tout_str_fee;
END;
END;
$cloveropen$;