<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="admin_reg.pid" label="住院号" @input="pidChanged($event)"></v-text-field>&emsp;&emsp;
          </v-flex>
          <v-flex d-flex> <v-text-field v-model="admin_reg.patient_name" label="姓名" disabled></v-text-field>&emsp;&emsp; </v-flex>
          <v-flex d-flex> <v-text-field v-model="admin_reg.in_type" label="就诊类别" disabled></v-text-field>&emsp;&emsp; </v-flex>
          <v-flex d-flex> <v-text-field v-model="admin_reg.patient_type" label="患者类别" disabled></v-text-field>&emsp;&emsp; </v-flex>
          <v-flex d-flex> <v-text-field v-model="admin_reg.pre_pay_left" label="预交金余额" disabled></v-text-field>&emsp;&emsp; </v-flex>
          <v-flex d-flex>
            >&emsp;&emsp;
            <v-text-field v-model="admin_reg.all_sum" label="住院总费用" disabled></v-text-field>
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="admin_reg.diag_name" label="入院诊断" disabled></v-text-field>&emsp;&emsp;
          </v-flex>
          <v-flex d-flex> <v-text-field v-model="admin_reg.addr_street" label="住址" disabled></v-text-field>&emsp;&emsp; </v-flex>
        </v-layout>
      </v-card-text>
    </v-card>
    <div>
      <v-toolbar dark color="teal">
        <v-toolbar-title>选择收费项目</v-toolbar-title>
        <v-autocomplete
          v-model="item_code"
          :loading="loading"
          :items="items_dictitem"
          item-text="item-text"
          item-value="item-value"
          :search-input.sync="search_dictitem"
          cache-items
          class="mx-4"
          flat
          hide-no-data
          hide-details
          label="补收收费项目"
          solo-inverted
          hint="请输入两个以上的收费项目关键字"
        ></v-autocomplete>
        <v-btn icon>
          <v-icon>mdi-dots-vertical</v-icon>
        </v-btn>
        数量
        <v-btn icon>
          <v-icon>mdi-dots-vertical</v-icon>
        </v-btn>
        <v-text-field v-model="item_num" label="数量" required single-line></v-text-field>
      </v-toolbar>
    </div>
    <!--------------------------结算信息栏----------------------------------------------- -->
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex
            ><v-spacer></v-spacer>
            <v-btn :disabled="!valid" color="success" @click="fee_add">确认记帐</v-btn>
            <v-btn :disabled="!valid" color="success" @click="sch_fee(admin_reg.pid)">查询明细</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <!-- -------------------------费用明细栏 --------------------------------------------- -->
    <v-card>
      <v-card-title>
        患者住院费用明细表
      </v-card-title>
      <v-data-table :headers="headers" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
    </v-card>
  </v-container>
</template>

<script>
import { get_regopcode, schadmfee, getdict_item, fee_admreg_add } from "../scripts/adm_reg.js";
export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    admin_reg: {
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
    item_code: "",
    items_dictitem: [],
    search_dictitem: null,
    loading: false,
    item_num: 1,
    headers: [
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
      { text: "医师", value: "cal_opcode" }
    ],
    fee_details: []
  }),

  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    console.log("mounted");
  },
  watch: {
    search_dictitem(val) {
      val && val !== this.select && this.querySelectionItems(val);
    }
  },
  methods: {
    querySelectionItems(v) {
      this.loading = true;
      console.log("v=" + v + "v.length=" + v.length);
      if (v.length < 2) {
        return;
      }
      getdict_item(v, this.topcode, this.tgc).then(data => {
        this.items_dictitem = data;
      });
      this.loading = false;
    },
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
      console.log("pid=" + e);    
      let tpid = e.trim();
      schadmfee(tpid, this.topcode, this.tgc).then(data => {
        console.log("schadmfee data=" + data);
        //let tjson_data = JSON.parse(data);
        let tlist = Array.of();
        tlist = data.split("|"); 
        console.log("-----tlist[0]=" + tlist[0]+ "   tlist[1]=" +tlist[1]);
        let tjson_adm = JSON.parse(tlist[0]);
        let tjson_fee = JSON.parse(tlist[1]);
        this.admin_reg = tjson_adm;
        this.fee_details = tjson_fee;

      });
    },
    sch_fee(tpid) {
      schadmfee(tpid, this.topcode, this.tgc).then(data => {        
        let tlist = Array.of();
        tlist = data.split("|"); 
        let tjson_adm = JSON.parse(tlist[0]);
        let tjson_fee = JSON.parse(tlist[1]);
        this.admin_reg = tjson_adm;
        this.fee_details = tjson_fee;

      });
    },
    fee_add() {
      if (this.admin_reg.pid.length<10){
        window.alert("请选择在院患者")
        return ;
      }
      let tin_str = this.admin_reg.pid + "|" + this.item_code + "|" + this.item_num + "|" + process.env.VUE_APP_HSP_CODE + "|" + this.topcode + "|" +this.tgc;
      fee_admreg_add(tin_str).then(data => {
        console.log("fee_add data=" + data);
        let tjson_fee = JSON.parse(data);
        if (tjson_fee.ResultCode=='0'){
          window.alert("补记住院收款成功");
        }else{
          window.alert("补记费用失败"+tjson_fee.ErrorMsg);
        }
      });
    }
    // ---------------------end methods----------------
  }
};
</script>
