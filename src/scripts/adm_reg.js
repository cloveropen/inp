//-------------------------获取患者类别-----------------------------------------------------------
export function getpatient_type(topcode, tgc) {
  let patient_types = Array.of(); //患者类别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/per_cate/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {      
      patient_types.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName        
      });
    }
    return patient_types;
  });
  return patient_types;
}

//---------------------------------------获取性别列表----------------------------------------------
export function getgender(topcode, tgc) {
  let genders = Array.of(); //性别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/gender_type/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      genders.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return genders;
  });
  return genders;
}

//---------------------------查询身份证件类型列表--------------------------------------------------
export function getid_type(topcode, tgc) {
  let idcard_types = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/id_type/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      idcard_types.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return idcard_types;
  });
  return idcard_types;
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
export function getin_type(topcode, tgc) {
  let in_types = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_type/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_types.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return in_types;
  });
  return in_types;
}
//---------------------------查询民族-------------------------------------------------------------------
export function getnation(topcode, tgc) {
  let nations = Array.of(); 
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/nation/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      nations.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return nations;
  });
  return nations;
}

//---------------------------查询家庭成员关系------------------------------------------------------------------
export function getliaison_rels(topcode, tgc) {
  let liaison_rels = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/family_rel/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      liaison_rels.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return liaison_rels;
  });
  return liaison_rels;
}
//---------------------------查询入院时情况------------------------------------------------------------------
export function getin_status(topcode, tgc) {
  let  in_statuss = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_status/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_statuss.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return in_statuss;
  });
  return in_statuss;
}
//---------------------------查询住院原因------------------------------------------------------------------
export function getin_purpose(topcode, tgc) {
  let in_purposes = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_INP_URL + "/searchdicthealthterm/in_purpose/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      in_purposes.splice(i, 0, {
        "item-value": tjson_obj[i].termId,
        "item-text": tjson_obj[i].termName
      });
    }
    return in_purposes;
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
    return tdiag_list;
  });
  return tdiag_list;
}
//-------------------------------------查询科室列表------------------------------------------------------
export function getdept_codes(topcode, tgc) {
  let dept_codes = Array.of(); //科室列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictdepartment/clinical/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    // console.log("getdept_codes data="+ data)
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      dept_codes.splice(i, 0, {
        "item-value": tjson_obj[i].deptCode,
        "item-text": tjson_obj[i].deptName
      });
    }
    return dept_codes;
  });
  return dept_codes;
}
//----------------------------------------查询本科室可以挂号的专家列表---------------------------------------------------
export function getdoctor_codes(tdept_code, tpost_tech, topcode, tgc) {
  let doctor_codes = Array.of(); //专家列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictperson/" + tdept_code + "/" + tpost_tech + "/";
  topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      doctor_codes.splice(i, 0, {
        "item-value": tjson_obj[i].personId,
        "item-text": tjson_obj[i].personName
      });
    }
    return doctor_codes;
  });
  return doctor_codes;
}
//------------------获取省份列表---------------------------
export function getprovs(topcode, tgc) {
  let addr_provs = Array.of(); //患者类别列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictprov/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {    
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_provs.splice(i, 0, {
        "item-value": tjson_obj[i].provinceId,
        "item-text": tjson_obj[i].name
      });
    }
    return addr_provs;
  });
  return addr_provs;
}

//------------------获取指定省份的市列表---------------------------
export function getcitys(tprovid, topcode, tgc) {
  let addr_citys = Array.of(); //市列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictcity/" + tprovid + "/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_citys.splice(i, 0, {
        "item-value": tjson_obj[i].cityId,
        "item-text": tjson_obj[i].name
      });
    }
    return addr_citys;
  });
  return addr_citys;
}

//------------------获取指定市的区县列表---------------------------
export function getcountys(tcityid, topcode, tgc) {
  let addr_countys = Array.of(); //指定市的区县列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictcounty/" + tcityid + "/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_countys.splice(i, 0, {
        "item-value": tjson_obj[i].countryId,
        "item-text": tjson_obj[i].name
      });
    }
    return addr_countys;
  });
  return addr_countys;
}

//------------------获取指定区县的街道列表---------------------------
export function getstreets(tcountyid, topcode, tgc) {
  let addr_townships = Array.of(); //指定区县的街道列表
  let turl = process.env.VUE_APP_INP_URL + "/searchdictstreet/" + tcountyid + "/" + topcode + "/" + tgc;
  fetch_data_api(turl).then(data => {
    let tjson_obj = JSON.parse(data);
    for (let i = 0; i < tjson_obj.length; i++) {
      addr_townships.splice(i, 0, {
        "item-value": tjson_obj[i].townId,
        "item-text": tjson_obj[i].name
      });
    }
    return addr_townships;
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

// -------------------------------------------------------------------------------------------------------------------------------------------
//---公用后台获取数据接口---------------------------------------
/*async function fetch_data_api(turl, tmethod) {
  let ret_data;
  await fetch(turl, {
    method: tmethod,
    headers: {
      Accept: "text/html",
      "Content-Type": "application/json"
    }
  })
    .then(function(response) {
      if (response.ok) {
        // window.alert("---ok=");
      } else {
        window.alert("警告:" + turl + "查询失败:" + response.statusText);
      }
      return response.json();
    })
    .then(function(data) {
      ret_data = data;
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        ret_data = JSON.parse(data.outdata);
      } else {
        //返回失败数据
        console.log("查询失败:" + data.errorMsg);
        window.alert("查询失败:" + data.errorMsg);
      }
      return ret_data;
    })
    .catch(function(err) {
      console.log("查询error=" + err);
      window.alert("查询error=" + err);
      return err;
    });
  //console.log("ret_data="+JSON.stringify(ret_data));
  return await ret_data;
}*/
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

export async function post_cash_async(turl, tbody) {
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
