CREATE OR REPLACE FUNCTION clover_odr.inp_sch_feeday_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 通过住院号查询入院患者费用日清单 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 返回: 住院患者费用单项汇总列表

DECLARE
    tin_arrays text ARRAY;
	tpid clover_odr.adm_reg.pid%type; --住院号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码	
	
	curs_day CURSOR(tpid text,thsp_code text) FOR SELECT distinct date_trunc('day',cashtime) as cs FROM clover_odr.fee_detail
	    where hsp_code=thsp_code and pid = tpid order by cs;
	tcash_day timestamp;
	tday_sum numeric(12,4) := 0.00;
	tout_str text := '';
BEGIN		
	select string_to_array(tin_str,'|') into tin_arrays;
	tpid := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	execute 'DROP TABLE IF EXISTS t_fee_day';
    execute 'CREATE TEMP TABLE t_fee_day(seq bigint not null primary key,day text,day_sum text,'
		||'item_name text,price text,quantity text,units text,fee_type text,mi_code text,mi_degree text,cashtime text)';
	
	OPEN curs_day(tpid, thsp_code);
	LOOP
      FETCH curs_day INTO tcash_day;
	  -- exit when no more row to fetch
	  EXIT WHEN NOT FOUND;
	  SELECT coalesce(sum(real_price*quantity*days),0.00) into tday_sum
		FROM clover_odr.fee_detail where presc_status<>'9'
		and hsp_code=thsp_code and pid=tpid
		and date_trunc('day',cashtime)=tcash_day;	
	  INSERT INTO t_fee_day(seq,day,day_sum,item_name,price,quantity,units,fee_type,mi_code,mi_degree,cashtime) 
	  values(nextval('clover_odr.seq_fee_detail_day'),to_char(tcash_day,'YYYY-MM-DD'),to_char(tday_sum,'999999990.00'),'','','','','','','','');	  
	  
	  -----------下面写入明细-------------------------------------------
	  INSERT INTO t_fee_day(seq,day,day_sum,item_name,price,quantity,units,fee_type,mi_code,mi_degree,cashtime)
	  SELECT nextval('clover_odr.seq_fee_detail_day'),'','',item_name,real_price::text,(quantity*days)::text,units,item_class,mi_code,mi_degree,to_char(cashtime,'YYYY-MM-DD HH24:MI:SS')
	      FROM clover_odr.fee_detail 
		  where presc_status<>'9'
			and hsp_code=thsp_code and pid=tpid
			and date_trunc('day',cashtime)=tcash_day;

   END LOOP;
   -- Close the cursor
   CLOSE curs_day;
		
	--查询费用明细
	SELECT json_agg(row_to_json(t_fee_day.*)) into tout_str FROM t_fee_day;	
	---------------------------------
	---返回json字符串数组
	
    RETURN tout_str;
END;
$cloveropen$;