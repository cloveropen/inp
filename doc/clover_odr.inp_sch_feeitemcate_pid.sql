CREATE OR REPLACE FUNCTION clover_odr.inp_sch_feeitemcate_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 通过住院号查询入院患者费用单项汇总列表 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 返回: 住院患者费用单项汇总列表

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码	
	
	curs_itemcate CURSOR FOR SELECT term_id, term_name FROM clover_md.dict_health_term where class_id='item_cate' order by term_id;
	tcate_id text;
	tcate_name text;
	tcate_sum numeric(12,4);
	
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	execute 'DROP TABLE IF EXISTS t_fee_cate';
    execute 'CREATE TEMP TABLE t_fee_cate(cate_id text not null primary key,cate_name text,cate_sum numeric(12,4))';
	
	OPEN curs_itemcate;
	LOOP
      FETCH curs_itemcate INTO tcate_id,tcate_name;
	  -- exit when no more row to fetch
	  EXIT WHEN NOT FOUND;
	  SELECT coalesce(sum(o.real_price*o.quantity*o.days),0.00) into tcate_sum
		FROM clover_odr.fee_detail o,clover_md.dict_item m
		where o.item_code = m.item_code 
		and left(m.fee_type,2)=tcate_id 
		and o.pid=tpid and hsp_code=thsp_code;
	  INSERT INTO t_fee_cate values(tcate_id,tcate_name,tcate_sum);
   END LOOP;
   -- Close the cursor
   CLOSE curs_itemcate;
		
	--查询费用明细
	SELECT json_agg(row_to_json(t_fee_cate.*)) into tout_str FROM t_fee_cate;	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str;
END;
$cloveropen$;