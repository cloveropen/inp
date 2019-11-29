CREATE OR REPLACE FUNCTION clover_odr.inp_sch_admreg_pid(tin_str text,tip text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $cloveropen$
-- 通过门诊号查询填充入院登记信息 入参:tpid + "|" + thsp_code + "|" + topcode + "|" + tgc;
-- 先查询门急诊入院通知单,如果没有查询挂号记录
-- 患者办理入院必须至少有门诊挂号记录

DECLARE
    tin_arrays text ARRAY;
	tpid_out clover_odr.adm_reg.pid_out%type; --门诊号
	thsp_code clover_odr.adm_reg.hsp_code%type;  --医院编码
	topcode clover_odr.adm_reg.opcode%type;  -- 交班操作员
	tpat_retain clover_odr.pat_retain%rowtype;
	tadm_reg clover_odr.adm_reg%rowtype;
	tout_reg clover_odr.out_reg%rowtype;
	
	tout_str text := '';
BEGIN		
	select  string_to_array(tin_str,'|') into tin_arrays;
	tpid_out := tin_arrays[1];
	thsp_code := tin_arrays[2];	
	topcode := tin_arrays[3];
	
	--查询门急诊医生入院通知单表
	SELECT * into tpat_retain FROM clover_odr.pat_retain
		where hsp_code=thsp_code and pid=tpid_out and cancel_flag<>'-1' order by seq desc limit 1	;
	if coalesce(tpat_retain.seq,0)=0 then --没有在入院通知单中找到数据
		SELECT * into tout_reg FROM clover_odr.out_reg 
		where hsp_code=thsp_code and pid=tpid_out and reg_cancel<>'-1' order by seq desc limit 1	;
		if coalesce(tout_reg.seq,0)=0 then --没有找到数据,返回空值
			tadm_reg.seq := -1;
			tadm_reg.hsp_code := thsp_code;
			tadm_reg.pid := '';
			tadm_reg.ex_pid := '';
			tadm_reg.patient_name := '';
			tadm_reg.in_num := 1;
			tadm_reg.gender := '';
			tadm_reg.patient_type := '';
			tadm_reg.in_type := '';
			tadm_reg.idcard := '';
			tadm_reg.idcard_type := '';
			tadm_reg.nation := '';
			tadm_reg.birth_date := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.age_y := 0;
			tadm_reg.age_m := 0;
			tadm_reg.age_d := 0;
			tadm_reg.addr_prov := '';
			tadm_reg.addr_city := '';
			tadm_reg.addr_county := '';
			tadm_reg.addr_township := '';
			tadm_reg.addr_street := '';
			tadm_reg.addr_house_nmb := '';
			tadm_reg.tel := '';
			tadm_reg.liaison := '';
			tadm_reg.liaison_tel := '';
			tadm_reg.liaison_rel := '';
			tadm_reg.health_id := '';
			tadm_reg.micard := '';
			tadm_reg.mi_company := '';
			tadm_reg.mi_str := '';
			tadm_reg.mi_type := '';
			tadm_reg.mi_pacc_left := 0;
			tadm_reg.in_resource := '';
			tadm_reg.pid_out := '';
			tadm_reg.doctor_out := '';
			tadm_reg.in_notice_nmb := '';
			tadm_reg.doctor_in_charge := '';
			tadm_reg.doctor_visit_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.all_sum := 0;
			tadm_reg.pre_pay_sum := 0;
			tadm_reg.pre_pay_left := 0;
			tadm_reg.pre_reg_flag := '';
			tadm_reg.green_flag := '';
			tadm_reg.in_cancel :='0';
			tadm_reg.in_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.opcode := '';
			tadm_reg.diag_id := '';
			tadm_reg.diag_name := '';
			tadm_reg.diag_id2 := '';
			tadm_reg.diag_name2 := '';
			tadm_reg.diag_id3 := '';
			tadm_reg.diag_name3 := '';
			tadm_reg.in_purpose := '';
			tadm_reg.room := '';
			tadm_reg.bed_nmb := '';
			tadm_reg.bed_degree := '';
			tadm_reg.dept_code := '';
			tadm_reg.dept_code2 := '';
			tadm_reg.out_hsp := '';
			tadm_reg.in_status := '';
			tadm_reg.hbsag_flag := '';
			tadm_reg.hcv_flag := '';
			tadm_reg.hiv_flag := '';
			tadm_reg.allergen_type := '';
			tadm_reg.abo_blood_group := '';
			tadm_reg.remark := '';
			tadm_reg.mch_ip := '';
		else
		-----------------------------------门诊挂号表填写入院登记信息begin--------------------------------------------------------------
			tadm_reg.seq := 0;
			tadm_reg.hsp_code := thsp_code;
			tadm_reg.pid := '';
			tadm_reg.ex_pid := tout_reg.ex_pid;
			tadm_reg.patient_name := tout_reg.patient_name;
			tadm_reg.in_num := 1;
			tadm_reg.gender := tout_reg.gender;
			tadm_reg.patient_type := tout_reg.patient_type;
			tadm_reg.in_type := '';
			tadm_reg.idcard := tout_reg.idcard;
			tadm_reg.idcard_type := tout_reg.idcard_type;
			tadm_reg.nation := '';
			tadm_reg.birth_date := tout_reg.birth_date;
			tadm_reg.age_y := tout_reg.age_y;
			tadm_reg.age_m := tout_reg.age_m;
			tadm_reg.age_d := tout_reg.age_d;
			tadm_reg.addr_prov := tout_reg.addr_prov;
			tadm_reg.addr_city := tout_reg.addr_city;
			tadm_reg.addr_county := tout_reg.addr_county;
			tadm_reg.addr_township := tout_reg.addr_township;
			tadm_reg.addr_street := tout_reg.addr_street;
			tadm_reg.addr_house_nmb := tout_reg.addr_house_nmb;
			tadm_reg.tel := '';
			tadm_reg.liaison := '';
			tadm_reg.liaison_tel := '';
			tadm_reg.liaison_rel := '';
			tadm_reg.health_id := '';
			tadm_reg.micard := tout_reg.micard;
			tadm_reg.mi_company := tout_reg.mi_company;
			tadm_reg.mi_str := '';
			tadm_reg.mi_type := '';
			tadm_reg.mi_pacc_left := 0;
			tadm_reg.in_resource := '门诊挂号转入院登记窗口';
			tadm_reg.pid_out := tout_reg.pid;
			tadm_reg.doctor_out := '';
			tadm_reg.in_notice_nmb := '';
			tadm_reg.doctor_in_charge := '';
			tadm_reg.doctor_visit_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.all_sum := 0;
			tadm_reg.pre_pay_sum := 0;
			tadm_reg.pre_pay_left := 0;
			tadm_reg.pre_reg_flag := '0';
			tadm_reg.green_flag := '0';
			tadm_reg.in_cancel :='0';
			tadm_reg.in_time := now();
			tadm_reg.opcode := topcode;
			tadm_reg.diag_id := '';
			tadm_reg.diag_name := '';
			tadm_reg.diag_id2 := '';
			tadm_reg.diag_name2 := '';
			tadm_reg.diag_id3 := '';
			tadm_reg.diag_name3 := '';
			tadm_reg.in_purpose := '';
			tadm_reg.room := '';
			tadm_reg.bed_nmb := '';
			tadm_reg.bed_degree := '';
			tadm_reg.dept_code := tout_reg.dept_code;
			tadm_reg.dept_code2 := '';
			tadm_reg.out_hsp := '';
			tadm_reg.in_status := '';
			tadm_reg.hbsag_flag := '';
			tadm_reg.hcv_flag := '';
			tadm_reg.hiv_flag := '';
			tadm_reg.allergen_type := '';
			tadm_reg.abo_blood_group := '';
			tadm_reg.remark := '';
			tadm_reg.mch_ip := '';
		-----------------------------------门诊挂号表填写入院登记信息end--------------------------------------------------------------
        end if;
	else
	----------------------------------------入院通知单表填写入院登记信息beg-----------------------------------------------------------
			tadm_reg.seq := 0;
			tadm_reg.hsp_code := thsp_code;
			tadm_reg.pid := '';
			tadm_reg.ex_pid := tpat_retain.ex_pid;
			tadm_reg.patient_name := tpat_retain.patient_name;
			tadm_reg.in_num := 1;
			tadm_reg.gender := tpat_retain.gender;
			tadm_reg.patient_type := tpat_retain.patient_type;
			tadm_reg.in_type := '';
			tadm_reg.idcard := tpat_retain.idcard;
			tadm_reg.idcard_type := '';
			tadm_reg.nation := tpat_retain.nation;
			tadm_reg.birth_date := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.age_y := tpat_retain.age_y;
			tadm_reg.age_m := tpat_retain.age_m;
			tadm_reg.age_d := tpat_retain.age_d;
			tadm_reg.addr_prov := tpat_retain.addr_prov;
			tadm_reg.addr_city := tpat_retain.addr_city;
			tadm_reg.addr_county := tpat_retain.addr_county;
			tadm_reg.addr_township := tpat_retain.addr_township;
			tadm_reg.addr_street := tpat_retain.addr_street;
			tadm_reg.addr_house_nmb := tpat_retain.addr_house_nmb;
			tadm_reg.tel := tpat_retain.tel;
			tadm_reg.liaison := tpat_retain.liaison;
			tadm_reg.liaison_tel := tpat_retain.liaison_tel;
			tadm_reg.liaison_rel := tpat_retain.liaison_rel;
			tadm_reg.health_id := tpat_retain.health_id;
			tadm_reg.micard := tpat_retain.micard;
			tadm_reg.mi_company := '';
			tadm_reg.mi_str := '';
			tadm_reg.mi_type := '';
			tadm_reg.mi_pacc_left := 0;
			tadm_reg.in_resource := '门急诊医生接诊转住院登记窗口';
			tadm_reg.pid_out := tpid_out;
			tadm_reg.doctor_out := tpat_retain.retain_doctor;
			tadm_reg.in_notice_nmb := tpat_retain.seq;
			tadm_reg.doctor_in_charge := '';
			tadm_reg.doctor_visit_time := to_timestamp('1900-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS');
			tadm_reg.all_sum := 0;
			tadm_reg.pre_pay_sum := 0;
			tadm_reg.pre_pay_left := 0;
			tadm_reg.pre_reg_flag := '0';
			tadm_reg.green_flag := '0';
			tadm_reg.in_cancel :='0';
			tadm_reg.in_time := now();
			tadm_reg.opcode := topcode;
			tadm_reg.diag_id := tpat_retain.diag_id;
			tadm_reg.diag_name := tpat_retain.diag_name;
			tadm_reg.diag_id2 := tpat_retain.diag_id2;
			tadm_reg.diag_name2 := tpat_retain.diag_name2;
			tadm_reg.diag_id3 := tpat_retain.diag_id3;
			tadm_reg.diag_name3 := tpat_retain.diag_name3;
			tadm_reg.in_purpose := '';
			tadm_reg.room := '';
			tadm_reg.bed_nmb := '';
			tadm_reg.bed_degree := '';
			tadm_reg.dept_code := tpat_retain.dept_code;
			tadm_reg.dept_code2 := tpat_retain.dept_code2;
			tadm_reg.out_hsp := tpat_retain.out_hsp;
			tadm_reg.in_status := tpat_retain.in_status;
			tadm_reg.hbsag_flag := tpat_retain.hbsag_flag;
			tadm_reg.hcv_flag := tpat_retain.hcv_flag;
			tadm_reg.hiv_flag := tpat_retain.hiv_flag;
			tadm_reg.allergen_type := tpat_retain.allergen_type;
			tadm_reg.abo_blood_group := '';
			tadm_reg.remark := tpat_retain.remark;
			tadm_reg.mch_ip := '';
	----------------------------------------入院通知单表填写入院登记信息end-----------------------------------------------------------
    end if;	
	
	---------------------------------
	---返回json字符串数组
	SELECT row_to_json(tadm_reg.*) into tout_str ;
	
    RETURN tout_str;
END;
$cloveropen$;