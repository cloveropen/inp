<template>
  <v-container class="grey lighten-5">
    <v-form ref="form" v-model="valid" lazy-validation>
      <v-card class="mx-auto" max-width="99%" min-width="100%">
        <v-img class="white--text" height="60px" :src="require('../assets/outreg.jpg')">
          <v-card-title class="align-end fill-height">出院结算</v-card-title>
        </v-img>
        <v-card-text>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field v-model="adm_reg.pid" label="住院号" @input="pidChanged($event)"> </v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.patient_name" label="患者姓名" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="adm_reg.patient_type"
                label="患者类型"
                required
                :items="patient_types"
                item-text="item-text"
                item-value="item-value"
                hide-details
                readonly
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select v-model="adm_reg.in_type" label="医疗类别" required :items="in_types" item-text="item-text" item-value="item-value" hide-details readonly></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="adm_reg.dept_code"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="住院科室"
                hide-details
                prepend-icon="group_work"
                readonly
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.diag_name" label="出院诊断" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.diag_name2" label="第二诊断" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.diag_name3" label="第三诊断" readonly></v-text-field>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                :items="out_mode_list"
                v_model="discharge.out_mode"
                item-text="item-text"
                item-value="item-value"
                label="出院方式"
                hide-details
                prepend-icon="group_work"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                :items="treate_result_list"
                v_model="discharge.treate_result"
                item-text="item-text"
                item-value="item-value"
                label="治疗结果"
                hide-details
                prepend-icon="group_work"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                :items="out_dest_list"
                v_model="discharge.out_dest"
                item-text="item-text"
                item-value="item-value"
                label="出院去向"
                hide-details
                prepend-icon="group_work"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-radio-group row v-model="middle_flag">
                <v-flex d-flex><v-radio key="normal" label="正常出院" value="normal"></v-radio></v-flex>
                <v-flex d-flex><v-radio key="middle" label="中途结算" value="middle"></v-radio></v-flex>
              </v-radio-group>
            </v-flex>
          </v-layout>
          <!-- <v-spacer></v-spacer>           -->
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
            <v-radio-group row v-model="pay_type">
              <v-flex d-flex><v-radio key="cash" label="现金" value="cash"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="wechat" label="微信" value="wechat"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="alipay" label="支付宝" value="alipay"></v-radio></v-flex>
            </v-radio-group>

            <v-btn color="success" >读健康卡</v-btn>
            <v-btn color="success" v-on:click="readcardClicked($event)">读医保卡</v-btn>
            <v-btn :disabled="!valid" color="success" @click="presettle">预结算</v-btn>
            <v-btn :disabled="!valid" color="success" @click="outregcashClicked($event)">出院登记</v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">出院结算 </v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">打印结算收据 </v-btn>
            <v-btn :disabled="valid" color="success" @click="schweixinClicked($event)">
              查询微信订单
            </v-btn>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>

          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
            
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>
        </v-card-actions>
      </v-card>
    </v-form>
    <v-expansion-panels popout focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple><b>出院结算表</b></v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院结算栏 --------------------------------------------- -->
          <v-data-table :headers="headers_discharge" :items="discharges" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>费用明细表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------明细表 --------------------------------------------- -->
          <v-data-table :headers="headers_fee_details" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>项目明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------项目明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers_item_details" :items="item_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>分类表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------分类表 --------------------------------------------- -->
          <v-data-table :headers="headers_cate_details" :items="cate_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>日清单</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------日清单 --------------------------------------------- -->
          <v-data-table :headers="headers_day_details" :items="day_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>预交金表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------预交金表 --------------------------------------------- -->
          <v-data-table :headers="headers_deposit_details" :items="deposit_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退费明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退费明细 --------------------------------------------- -->
          <v-data-table :headers="headers_fee_details" :items="fee_cancel_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院结算召回记录</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院结算召回记录 --------------------------------------------- -->
          <v-data-table :headers="headers_discharge" :items="discharge_cancels" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院登记信息</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院登记取消记录 --------------------------------------------- -->
          <v-data-table :headers="headers_admreg_cancel" :items="adm_reg_cancels" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
    <v-card>
      <v-card-title>
        在院患者表
        <div class="flex-grow-1"></div>
        <v-text-field v-model="search_name" append-icon="search" label="姓名关键字" single-line hide-details></v-text-field>
        <v-btn color="warning" dark @click="sch_admreg_listname($event)">按姓名查询</v-btn>
      </v-card-title>
      <v-data-table :headers="headers_admreg" :items="admreg_list" item-key="seq" @click:row="select_admreg"></v-data-table>
    </v-card>
    <v-row>
      <v-col>
        <v-card class="pa-2" outlined style="background-color: lightgrey;" tile>
          出院结算收据打印样式
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import {
  get_regopcode,
  gettreate_result,
  getout_mode,
  getout_dest,
  getadmreg_list,
  getadmreg_list_name,
  fetch_data_api,
  getpatient_type,
  getin_type,
  getdept_codes
} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    pay_type: "cash",
    middle_flag: "normal",
    patient_types: [], //患者类别列表
    dept_codes: [], //就诊科室列表
    in_types: [], //入院医疗类别
    out_mode_list: [], //出院方式
    treate_result_list: [], //治疗结果
    out_dest_list: [], //实际出院去向
    adm_reg: {
      hsp_code: process.env.VUE_APP_HSP_CODE,
      pid: "",
      ex_pid: "",
      patient_name: "",
      in_num: 1,
      gender: "",
      patient_type: "",
      in_type: "",
      idcard: "",
      nation: "",
      idcard_type: "",
      birth_date: "",
      age_y: 0,
      age_m: 0,
      age_d: 0,
      addr_prov: process.env.VUE_APP_HSP_PROV,
      addr_city: process.env.VUE_APP_HSP_CITY,
      addr_county: process.env.VUE_APP_HSP_COUNTY,
      addr_township: "",
      addr_street: "",
      addr_house_nmb: "",
      tel: "",
      liaison: "",
      liaison_tel: "",
      liaison_rel: "",
      health_id: "",
      micard: "",
      mi_conpany: "",
      mi_str: "",
      mi_type: "",
      mi_pacc_left: 0.0,
      in_resource: "",
      pid_out: "",
      doctor_out: "",
      in_notice_nmb: "",
      doctor_in_charge: "",
      doctor_visit_time: "",
      all_sum: 0.0,
      pre_pay_sum: 0.0,
      pre_pay_left: 0.0,
      pre_reg_flag: "",
      green_flag: "",
      in_cancel: "0",
      in_time: "",
      opcode: "",
      diag_id: "",
      diag_name: "",
      diag_id2: "",
      diag_name2: "",
      diag_id3: "",
      diag_name3: "",
      in_purpose: "",
      room: "",
      bed_nmb: "",
      bed_degree: "",
      dept_code: "",
      dept_code2: "",
      out_hsp: "",
      in_status: "", //入院病情状态
      hbsag_flag: "",
      hcv_flag: "",
      hiv_flag: "",
      allergen_type: "",
      abo_blood_group: ""
    },
    discharge: {
      seq: 0,
      hsp_code: "",
      pid: "",
      ex_pid: "",
      patient_name: "",
      patient_type: "",
      in_type: "",
      idcard: "",
      micard: "",
      health_id: "",
      mi_conpany: "",
      mi_type: "",
      mi_pacc_left: 0.0,
      invoice_nmb: "",
      flow_nmb: "",
      in_time: "",
      out_time: "",
      settle_time: "",
      opcode: "",
      diag_id: "",
      diag_name: "",
      diag_id2: "",
      diag_name2: "",
      diag_id3: "",
      diag_name3: "",
      middle_flag: "",
      dept_code_out: "",
      dept_code_out2: "",
      out_mode: "",
      treate_result: "",
      out_dest: "",
      cancel_flag: "",
      all_sum: 0.0,
      cash_sum: 0.0,
      pacc_sum: 0.0,
      fund_sum: 0.0,
      fund_nh_sum: 0.0,
      fund_commeric: 0.0,
      weixin_sum: 0.0,
      alipay_sum: 0.0,
      unionpay_sum: 0.0,
      check_sum: 0.0,
      voucher_sum: 0.0,
      spec_sum: 0.0,
      in_num: 0,
      indays: 0,
      pre_cash: 0.0,
      pre_check: 0.0,
      pre_weixin: 0.0,
      pre_alipay: 0.0,
      pre_union: 0.0,
      change_cash: 0.0,
      change_check: 0.0,
      change_weixin: 0.0,
      change_alipay: 0.0,
      change_union: 0.0
    },
    headers_admreg: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "住院号", value: "pid" },
      { text: "总费用", value: "all_sum" },
      { text: "预交金余额", value: "pre_pay_left" },
      { text: "人员类别", value: "patient_type" },
      { text: "医疗类别", value: "in_type" },
      { text: "入院时间", value: "in_time" },
      { text: "住院科室", value: "dept_code" }
    ],
    headers_admreg_cancel: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "住院号", value: "pid" },
      { text: "总费用", value: "all_sum" },
      { text: "预交金余额", value: "pre_pay_left" },
      { text: "人员类别", value: "patient_type" },
      { text: "医疗类别", value: "in_type" },
      { text: "入院时间", value: "in_time" },
      { text: "住院科室", value: "dept_code" },
      { text: "取消出院登记时间", value: "cancel_time" }
    ],
    headers_discharge: [ //出院结算表头
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "住院号", value: "pid" },
      { text: "总费用", value: "all_sum" }
    ],
    headers_fee_details: [   //费用明细表头
      {
        text: "项目名称",
        align: "left",
        sortable: false,
        value: "item_name"
      },
      { text: "单价", value: "real_price" },
      { text: "数量", value: "quantity" },
      { text: "天数", value: "days" },
      { text: "开具时间", value: "cal_time" },
      { text: "医师", value: "cal_opcode" },
      { text: "收款时间", value: "cashtime" },
      { text: "收款人", value: "	cash_opcode" },
      { text: "执行时间", value: "exec_time" },
      { text: "执行人", value: "exec_opcode" }
    ],
    headers_item_details: [   //项目明细表头
      {
        text: "项目名称",
        align: "left",
        sortable: false,
        value: "item_name"
      },
      { text: "平均单价", value: "price" },
      { text: "数量合计", value: "item_num" },
      { text: "单位", value: "units" },
      { text: "金额", value: "item_sum" },
      { text: "项目编码", value: "item_code" }
    ],
    headers_cate_details: [   //分类表头
      {
        text: "类别名称",
        align: "center",
        sortable: false,
        value: "cate_name"
      },
      { text: "金额", value: "cate_sum" }     
    ],
    headers_day_details: [   //日清单表头
      {
        text: "日期",
        align: "left",
        sortable: false,
        value: "day"
      },
      { text: "日金额", value: "day_sum" },   
      { text: "项目名称", value: "item_name" },
      { text: "数量", value: "quantity" },
      { text: "单位", value: "units" },
      { text: "单价", value: "price" },
      { text: "医保等级", value: "mi_degree" },
      { text: "项目分类", value: "fee_type" }
    ],
    headers_deposit_details: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "住院号", value: "pid" },
      { text: "预交金", value: "pay_sum" },
      { text: "支付时间", value: "pay_time" },
      { text: "操作员", value: "opcode" },
      { text: "现金", value: "pay_cash" },
      { text: "微信", value: "pay_weixin" },
      { text: "支付宝", value: "pay_alipay" },
      { text: "银联", value: "pay_union" },
      { text: "支票", value: "pay_chk" },
      { text: "其他支付", value: "pay_other" },
      { text: "备注", value: "remark" },
      { text: "开户行", value: "bank" },
      { text: "帐号", value: "account" }
    ],
    admreg_list: [],
    discharges: [],
    fee_details: [],
    item_details: [],
    cate_details: [],
    day_details: [],
    deposit_details: [],
    fee_cancel_details: [],
    discharge_cancels: [],
    adm_reg_cancels: [],
    search_name: ""
  }),
  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    gettreate_result(this.topcode, this.tgc).then(data => {
      this.treate_result_list = data;
    });
    getout_mode(this.topcode, this.tgc).then(data => {
      this.out_mode_list = data;
    });
    getout_dest(this.topcode, this.tgc).then(data => {
      this.out_dest_list = data;
    });
    getadmreg_list(this.topcode, this.tgc).then(data => {
      this.admreg_list = JSON.parse(data);
    });
    getpatient_type(this.topcode, this.tgc).then(data => {
      this.patient_types = data;
    });
    getin_type(this.topcode, this.tgc).then(data => {
      this.in_types = data;
    });
    getdept_codes(this.topcode, this.tgc).then(data => {
      this.dept_codes = data;
    });
  },
  methods: {
    validate() {
      if (this.$refs.form.validate()) {
        this.snackbar = true;
      }
    },
    reset() {
      this.$refs.form.reset();
    },
    resetValidation() {
      this.$refs.form.resetValidation();
    },
    pidChanged(e) {
      let tpid = e;
      if (tpid.length < 10) {
        return;
      }
      let tinstr = tpid + "|" + process.env.VUE_APP_HSP_CODE;
      let turl = process.env.VUE_APP_INP_URL + "/searchadmregmulti/pid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        console.log("pidChanged data=" + data);
        let tjson_data = JSON.parse(data);
        this.adm_reg = tjson_data;
      });
    },
    readcardClicked(e) {
      console.log("e=" + e.target.innerText);
      // readcard_mi();
    },
    outregcashClicked(e) {
      console.log("e=" + e.target.innerText);
    },
    outregweixinClicked(e) {
      console.log("e=" + e.target.innerText);
    },
    schweixinClicked(e) {
      console.log("e=" + e.target.innerText);
    },
    sch_admreg_listname(e) {
      console.log("点击" + e.target.innerText);
      let tname = this.search_name;
      if (tname.trim().length < 1) {
        window.alert("按姓名查询,姓名不能为空");
        return;
      } else {
        getadmreg_list_name(tname, this.topcode, this.tgc).then(data => {
          this.admreg_list = JSON.parse(data);
        });
      }
    },
    select_admreg(item) {
      let tpid = item.pid;
      let tinstr = tpid + "|" + process.env.VUE_APP_HSP_CODE;
      let turl = process.env.VUE_APP_INP_URL + "/searchadmregmulti/pid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        // console.log("select_admreg data=" + data);
        let tjson_data = JSON.parse(data);
        this.adm_reg = tjson_data;
      });
    },
    presettle() {
      let tpid = this.adm_reg.pid;
      let thsp_code = process.env.VUE_APP_HSP_CODE;
      //查询费用明细表
      let tinstr = tpid + "|" + thsp_code;
      let turl = process.env.VUE_APP_INP_URL + "/searchfee_multi/cash_in/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        // console.log("select_admreg data=" + data);
        let tjson_data = JSON.parse(data);
        this.fee_details = tjson_data;
      });
      //查询项目明细表(单项目汇总表)
      tinstr = tpid + "|" + thsp_code;
      turl = process.env.VUE_APP_INP_URL + "/searchfee_multi/cash_in_by_item/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        let tjson_data = JSON.parse(data);
        this.item_details = tjson_data;
      });
      //查询费用分类表
      tinstr = tpid + "|" + thsp_code + "|" + this.topcode ;
      turl = process.env.VUE_APP_INP_URL + "/searchfee_multi/cash_in_by_cateid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        let tjson_data = JSON.parse(data);
        this.cate_details = tjson_data;
      });
      //查询日清单
      tinstr = tpid + "|" + thsp_code + "|" + this.topcode ;
      turl = process.env.VUE_APP_INP_URL + "/searchfee_multi/cash_in_by_day/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        let tjson_data = JSON.parse(data);
        this.day_details = tjson_data;
      });
      //查询预交金表
      tinstr = tpid + "|" + thsp_code+"|"+"in";
      turl = process.env.VUE_APP_INP_URL + "/searchdepositmulti/pid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        //console.log("查询预交金表 data=" + data);
        let tjson_data = JSON.parse(data);
        this.deposit_details = tjson_data;
      });
      //查询退费明细
      tinstr = tpid + "|" + thsp_code;
      turl = process.env.VUE_APP_INP_URL + "/searchfee_multi/cash_in_back/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        let tjson_data = JSON.parse(data);
        this.fee_cancel_details = tjson_data;
      });
      //查询出院结算召回记录
      tinstr = tpid + "|" + thsp_code;
      turl = process.env.VUE_APP_INP_URL + "/searchdischargemulti/pid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        // console.log("查询出院结算召回记录 data=" + data);
        let tjson_data = JSON.parse(data);
        this.discharge_cancels = tjson_data;
      });
      //查询出院登记取消记录
      tinstr = tpid + "|" + thsp_code;
      turl = process.env.VUE_APP_INP_URL + "/searchadmchkoutmulti/pid/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        console.log("查询出院登记取消记录 data=" + data);
        let tjson_data = JSON.parse(data);
        this.adm_reg_cancels = tjson_data;
      });
      //出院预结算操作,计算返回金额

    }
    // ---------------------end methods----------------
  }
};
</script>

<style></style>
