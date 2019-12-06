//-------------------------获取患者类别-----------------------------------------------------------
export async function getpatient_type(topcode, tgc) {
  let patient_types = Array.of(); //患者类别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/per_cate/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {      
      patient_types.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName        
      });
    }
  });
  return patient_types;
}
//---------------------------------------获取性别列表----------------------------------------------
export async function getgender(topcode, tgc) {
  let genders = Array.of(); //性别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/gender_type/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      genders.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return genders;
}
//---------------------------------------获取出院方式----------------------------------------------
export async function getout_mode(topcode, tgc) {
  let out_mode = Array.of();
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/out_mode/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      out_mode.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return out_mode;
}
//---------------------------------------获取治疗结果(医保出院原因)----------------------------------------------
export async function gettreate_result(topcode, tgc) {
  let treate_result = Array.of();
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/mi_outreason/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      treate_result.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return treate_result;
}
//---------------------------------------获取实际出院去向----------------------------------------------
export async function getout_dest(topcode, tgc) {
  let out_dest = Array.of();
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/out_dest/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      out_dest.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return out_dest;
}
//--------------------------查询操作员编号--------------------------------------------------------
export function get_regopcode() {
  let user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    return this.$parent.$router.push({ path: "/login" });
  }
  return user.opid + "|" + user.tgc;
}
//----------------------------查询入院医疗类别列表------------------------------------------------------
export async function getin_type(topcode, tgc) {
  let in_types = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_type/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_types.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return in_types;
}
//---------------------------查询民族-------------------------------------------------------------------
export async function getnation(topcode, tgc) {
  let nations = Array.of(); 
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/nation/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      nations.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return nations;
}
//---------------------------查询家庭成员关系------------------------------------------------------------------
export async function getliaison_rels(topcode, tgc) {
  let liaison_rels = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/family_rel/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      liaison_rels.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return liaison_rels;
}
//---------------------------查询入院时情况------------------------------------------------------------------
export async function getin_status(topcode, tgc) {
  let  in_statuss = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_status/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_statuss.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return in_statuss;
}
//---------------------------查询住院原因------------------------------------------------------------------
export async function getin_purpose(topcode, tgc) {
  let in_purposes = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_purpose/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_purposes.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
  });
  return in_purposes;
}
//---------------------------通过疾病名称关键字查询入院诊断------------------------------------------------------------------
export async function getdiag(tdiagname,topcode, tgc) {
  let tdiag_list = Array.of(); //诊断列表
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/searchdiagmi/%"+ tdiagname +"%/"
      + thsp_code + "/" + topcode + "/" + tgc;
  let tencode_url = encodeURI(turl);
  await fetch_data_api(tencode_url).then(data => {
    //console.log("getdiag data=" + data);
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      tdiag_list.splice(i, 0, {
        "item-value": tjson_obj[i].icd_id,
        "item-text": tjson_obj[i].icd_name
      });
    }
    // return tdiag_list;
  });
  return tdiag_list;
}
//---------------------------通过名称关键字查询诊疗项目词典------------------------------------------------------------------
export async function getdict_item(titemname,topcode, tgc) {
  let titem_list = Array.of(); //诊断列表
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/searchdictitem/%"+ titemname +"%/"
      + thsp_code + "/" + topcode + "/" + tgc;
  let tencode_url = encodeURI(turl);
  await fetch_data_api(tencode_url).then(data => {
    //console.log("getdiag data=" + data);
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      titem_list.splice(i, 0, {
        "item-value": tjson_obj[i].item_code,
        "item-text": tjson_obj[i].item_name+"("+tjson_obj[i].real_price+")"
      });
    }
    // return titem_list;
  });
  return titem_list;
}
//---------------------------查询门急诊医生收治病人入院通知单-----------------------------------------------------------------
export async function getpatretain(topcode, tgc) {
  let tout_str = "";
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/searchpatretain/"
      + thsp_code + "/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    tout_str = data;
  });
  return tout_str;
}
//----------通过门诊号查询入院通知单或挂号信息填充入院登记信息,先查询住院通知单,如果没有入院通知单则查询挂号信息,如果挂号信息也不存在返回空-----------------------------------------------------------------
export async function filladminregbypid(tpid,topcode, tgc) {
  let tout_str = "";
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/filladmreg/"
      + tpid + "/" + thsp_code + "/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    tout_str = data;
  });
  return tout_str;
}
//-------------------------------------查询科室列表------------------------------------------------------
export async function getdept_codes(topcode, tgc) {
  let dept_codes = Array.of(); //科室列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictdepartment/clinical/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    // console.log("getdept_codes data="+ data)
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      dept_codes.splice(i, 0, {
        "item-value": tjson_obj[i].deptCode,
        "item-text": tjson_obj[i].deptName
      });
    }
  });
  return dept_codes;
}
//---------------------------查询在院患者预交金列表-----------------------------------------------------------------
export async function getdeposit_list(tnum_lmt, tname, topcode, tgc) {
  // tnum_lmt 表示限制返回记录数,tname 表示姓名关键字
  let tout_str = "";
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/searchdeposit_list/"
      + tnum_lmt + "/" + tname + "/" + thsp_code + "/" + topcode + "/" + tgc;
  let tencode_url = encodeURI(turl);    
  await fetch_data_api(tencode_url).then(data => {
    tout_str = data;
  });
  return tout_str;
}
//---------------------------用在院患者登记信息填充预交金基本信息-----------------------------------------------------------------
export async function filldeposit(tpid, topcode, tgc) {
  let tout_str = "";
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/filldeposit/"
      + tpid + "/" + thsp_code + "/" + topcode + "/" + tgc;
  let tencode_url = encodeURI(turl);
  await fetch_data_api(tencode_url).then(data => {
    tout_str = data;
  });
  return tout_str;
}
//---------------------------通过住院号查询在院患者信息和费用明细-----------------------------------------------------------------
export async function schadmfee(tpid, topcode, tgc) {  
  let tout_str = "";
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl = process.env.VUE_APP_INP_URL + "/schadmfee/"
      + tpid + "/" + thsp_code + "/" + topcode + "/" + tgc;
  let tencode_url = encodeURI(turl);
  await fetch_data_api(tencode_url).then(data => {
    tout_str = data;
  });
  return tout_str;
}
//----------------------------------------查询本科室可以挂号的专家列表---------------------------------------------------
export async function getdoctor_codes(tdept_code, tpost_tech, topcode, tgc) {
  let doctor_codes = Array.of(); //专家列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictperson/" + tdept_code + "/" 
    + tpost_tech + "/" +  topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      doctor_codes.splice(i, 0, {
        "item-value": tjson_obj[i].personId,
        "item-text": tjson_obj[i].personName
      });
    }
  });
  return doctor_codes;
}
//------------------获取省份列表---------------------------
export async function getprovs(topcode, tgc) {
  let addr_provs = Array.of(); //患者类别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictprov/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {    
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_provs.splice(i, 0, {
        "item-value": tjson_obj[i].provinceId,
        "item-text": tjson_obj[i].name
      });
    }
  });
  return addr_provs;
}

//------------------获取指定省份的市列表---------------------------
export async function getcitys(tprovid, topcode, tgc) {
  let addr_citys = Array.of(); //市列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictcity/" + tprovid + "/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_citys.splice(i, 0, {
        "item-value": tjson_obj[i].cityId,
        "item-text": tjson_obj[i].name
      });
    }
  });
  return addr_citys;
}

//------------------获取指定市的区县列表---------------------------
export async function getcountys(tcityid, topcode, tgc) {
  let addr_countys = Array.of(); //指定市的区县列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictcounty/" + tcityid + "/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_countys.splice(i, 0, {
        "item-value": tjson_obj[i].countryId,
        "item-text": tjson_obj[i].name
      });
    }
  });
  return addr_countys;
}

//------------------获取指定区县的街道列表---------------------------
export async function getstreets(tcountyid, topcode, tgc) {
  let addr_townships = Array.of(); //指定区县的街道列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictstreet/" + tcountyid + "/" + topcode + "/" + tgc;
  await fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_townships.splice(i, 0, {
        "item-value": tjson_obj[i].townId,
        "item-text": tjson_obj[i].name
      });
    }
  });
  return addr_townships;
}

//------------------------确认微信挂号------------------------------------------------------------
export function outreg_weixin() {
  //console.log(this.$refs.form.data);
  console.log("确认微信挂号");
  return "";
}
//-------------------------查询微信订单-----------------------------------------------------------
export function sch_weixin() {
  // console.log(this.$refs.form.data);
  console.log("查询微信订单");
  return "";
}
//-------------------------入院登记确认-----------------------------------------------------------
export async function save_adminreg(tin_str) {
  let tout_Str = ""; //成功返回住院号|ok,失败返回-1|失败原因
  let turl = process.env.VUE_APP_INP_URL + "/save_admreg";
  await post_data_async(turl, tin_str).then(data => {
    tout_Str = JSON.stringify(data);
    return tout_Str;
  });
  return tout_Str;
}
//-------------------------补记住院费用-----------------------------------------------------------
export async function fee_admreg_add(tin_str) {
  let tout_Str = ""; //成功返回住院号|ok,失败返回-1|失败原因
  let turl = process.env.VUE_APP_INP_URL + "/fee_admreg_add";
  await post_data_async(turl, tin_str).then(data => {
    tout_Str = JSON.stringify(data);
    return tout_Str;
  });
  return tout_Str;
}
//-------------------------入院登记保存照片-----------------------------------------------------------
export async function save_adminreg_pic(tin_str) {
  let tout_Str = ""; //成功返回住院号|ok,失败返回-1|失败原因
  let turl = process.env.VUE_APP_INP_URL + "/save_admreg_pic";
  await post_data_async(turl, tin_str).then(data => {
    tout_Str = JSON.stringify(data);
    return tout_Str;
  });
  return tout_Str;
}
//-------------------------补预交金确认-----------------------------------------------------------
export async function deposit4cash(tin_str) {
  let tout_Str = ""; //成功返回发票号|ok,失败返回-1|失败原因
  let turl = process.env.VUE_APP_INP_URL + "/save_deposit";
  await post_data_async(turl, tin_str).then(data => {
    tout_Str = JSON.stringify(data);
    return tout_Str;
  });
  return tout_Str;
}
// -------------------------------------------------------------------------------------------------------------------------------------------
//---公用后台获取数据接口--------------------------------------
export async function fetch_data_api(turl) {
  try {
    let response = await fetch(turl, {
      method: "get",
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json"
      }
    });
    let data = await response.json();

    if (data.resultCode == "0") {
      return data.outdata;
    } else {
      console.log("查询失败:" + data.errorMsg);
      return "";
    }
  } catch (err) {
    console.error(err);
    // Handle errors here
  }
}

export async function post_data_async(turl, tbody) {
  try {
    let response = await fetch(turl, {
      method: "post",
      body: tbody,
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json"
      }
    });
    return await response.json();
  } catch (err) {
    console.error(err);
    // Handle errors here
  }
}
