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
              <v-text-field v-model="adm_reg.patient_type" label="患者类型" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.in_type" label="医疗类别" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="adm_reg.dept_code" label="住院科室" readonly></v-text-field>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
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
              <v-select :items="out_mode_list" v_model="discharge.out_mode" item-text="item-text" item-value="item-value" label="出院方式" hide-details prepend-icon="group_work"></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select :items="treate_result_list" v_model="discharge.treate_result" item-text="item-text" item-value="item-value" label="治疗结果" hide-details prepend-icon="group_work"></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select :items="out_dest_list" v_model="discharge.out_dest" item-text="item-text" item-value="item-value" label="出院去向" hide-details prepend-icon="group_work"></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-radio-group row v-model="pay_type">
                <v-flex d-flex><v-radio key="cash" label="正常出院" value="cash"></v-radio></v-flex>
                <v-flex d-flex><v-radio key="wechat" label="中途结算" value="wechat"></v-radio></v-flex>
              </v-radio-group>
            </v-flex>
          </v-layout>
          <!-- <v-spacer></v-spacer>           -->
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>

            <v-btn :disabled="!valid" color="success" @click="validate">查询</v-btn>
            <v-btn :disabled="!valid" color="success" @click="outregcashClicked($event)">出院登记</v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">出院结算 </v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">打印结算收据 </v-btn>
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
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>费用明细表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------明细表 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>项目明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------项目明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>分类表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------分类表 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>日清单</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------日清单 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>预交金表</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------预交金表 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退费明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退费明细 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院结算召回记录</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院结算召回记录 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院登记取消记录</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院登记取消记录 --------------------------------------------- -->
          <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
    <v-card>
      <v-card-title>
        在院患者表
        <div class="flex-grow-1"></div>
        <v-text-field v-model="search_name" append-icon="search" label="姓名关键字" single-line hide-details></v-text-field>
        <v-btn color="warning" dark @click="schdeposit_listname($event)">按姓名查询</v-btn>
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
  get_regopcode, gettreate_result, getout_mode, getout_dest
  //getin_status,
  //getin_purpose
} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    pay_type: "cash",
    out_mode_list: [],  //出院方式
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
      { text: "住院号", value: "pid" }
    ],
    admreg_list: []
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
    expidChanged(e) {
      let texpid = e;
      console.log("texpid e=" + e);
      if (texpid.length < 10) {
        return;
      }
    },
    readcardClicked(e) {
      console.log("e=" + e.target.innerText);
      // readcard_mi();
    },
    outregcashClicked(e) {
      console.log("e=" + e.target.innerText);
      // outreg_cash(this.out_reg).then(data =>{
      //   this.out_reg.pid = data;
      //   console.log("outregcashClicked this.out_reg_pic.pid=" +this.out_reg_pic.pid);
      //   this.out_reg_pic.pid = this.out_reg.pid;
      //   this.out_reg_pic.exPid = this.out_reg.exPid;
      //   this.out_reg_pic.patientName = this.out_reg.patientName;
      //   this.out_reg_pic.idcard = this.out_reg.idcard;
      //   this.out_reg_pic.healthId = this.out_reg.healthId;
      //   this.out_reg_pic.micard = this.out_reg.micard;
      //   this.out_reg_pic.captureOpid = this.out_reg.regOpcode;
      //   // outreg_pic(this.out_reg_pic);
      // });
    },
    outregweixinClicked(e) {
      console.log("e=" + e.target.innerText);
    },
    schweixinClicked(e) {
      console.log("e=" + e.target.innerText);
    },

    reg_typeChanged(e) {
      console.log("reg_typeChanged e=" + e);
      // let treg_type = this.out_reg.regType;
      // getregprice(treg_type).then(data => {
      //   this.out_reg.regPrice = data[0];
      //   this.out_reg.checkPrice = data[1];
      // });
    }
    // ---------------------end methods----------------
  }
};
</script>

<style></style>
