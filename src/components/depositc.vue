<template>
  <v-container class="grey lighten-5">
    <v-form ref="form" v-model="valid" lazy-validation>
      <v-card class="mx-auto" max-width="99%" min-width="100%">
        <v-img class="white--text" height="60px" :src="require('../assets/outreg.jpg')">
          <v-card-title class="align-end fill-height">补预交金</v-card-title>
        </v-img>
        <v-card-text>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field v-model="deposit.pid" label="住院号" @input="pidChanged($event)"> </v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.patient_name" label="患者姓名" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="deposit.patient_type"
                label="患者类型"
                readonly
                :items="patient_types"
                item-text="item-text"
                item-value="item-value"
                hide-details
                prepend-icon="map"
                single-line
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="deposit.in_type"
                label="医疗类别"
                readonly
                :items="in_types"
                item-text="item-text"
                item-value="item-value"
                hide-details
                prepend-icon="map"
                single-line
              ></v-select>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.ex_pid" label="患者主索引" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="deposit.dept_code"
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
              <v-text-field v-model="deposit.room" label="病区" readonly></v-text-field>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.bed_num" label="床位号" readonly></v-text-field>&emsp;&emsp;
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.pay_sum" label="补交预交金" suffix="元" class="headline mb-1"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.remark" label="备注"></v-text-field>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.bank" label="开户行"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.account" label="帐号"></v-text-field>
            </v-flex>
          </v-layout>
         
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
            <v-radio-group row v-model="pay_type">
              <v-flex d-flex><v-radio key="cash" label="现金" value="cash"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="wechat" label="微信" value="wechat"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="alipay" label="支付宝" value="alipay"></v-radio></v-flex>
            </v-radio-group>            
            <v-btn :disabled="!valid" color="success" @click="depositcash($event)">确认交款</v-btn>
            <v-btn :disabled="!valid" color="success" >打印预交金收据</v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">
              查询微信订单
            </v-btn>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>
        </v-card-actions>
      </v-card>
      <br/>
      <v-spacer></v-spacer>
       <v-divider inset dark></v-divider>
       <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="deposit.pay_cash" label="现金支付" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;
              <v-text-field v-model="deposit.pay_weixin" label="微信支付" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;
              <v-text-field v-model="deposit.pay_alipay" label="支付宝" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;
              <v-text-field v-model="deposit.pay_union" label="银联支付" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;
              <v-text-field v-model="deposit.pay_chk" label="支票支付" readonly></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;
              <v-text-field v-model="deposit.pay_other" label="其他支付" readonly></v-text-field>
            </v-flex>
          </v-layout>
          <v-divider inset></v-divider>
          <v-spacer></v-spacer>
    </v-form>

    <v-card>
      <v-card-title>
        患者预交金明细表
        <div class="flex-grow-1"></div>
        <v-text-field v-model="search_name" append-icon="search" label="姓名关键字" single-line hide-details></v-text-field>
        <v-btn color="warning" dark @click="schdeposit_listname($event)">按姓名查询</v-btn>
      </v-card-title>
      <v-data-table :headers="headers_deposit" :items="deposits_list" item-key="seq" @click:row="select_deposit"></v-data-table>
    </v-card>
    <v-row>
      <v-col>
        <v-card class="pa-2" outlined style="background-color: lightgrey;" tile>
          预交金收据打印样式
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { getpatient_type, get_regopcode, getin_type, getdept_codes, getdeposit_list, filldeposit, fetch_data_api, deposit4cash} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    pay_type: "cash",
    patient_types: [], //患者类别列表  
    in_types: [], //入院登记类别 
    dept_codes: [], //就诊科室列表
    deposit: {
      seq: 0,
      hsp_code: process.env.VUE_APP_HSP_CODE,
      pid: "",
      ex_pid: "",
      patient_name: "",
      patient_type: "",
      in_type: "",
      dept_code: "",
      dept_code2: "",
      room: "",
      bed_nmb: "",
      flow_nmb: "",
      invoice_nmb: "",
      apply_time: "",
      apply_opcode: "",
      pay_status: "",
      pay_time: "",
      opcode: "",
      bank: "",
      deposit_cancel: "0",
      pay_source: "住院处窗口",
      account: "",
      pay_sum: 0.0,
      pay_cash: 0.0,
      pay_weixin: 0.0,
      pay_alipay: 0.0,
      pay_union: 0.0,
      pay_chk: 0.0,
      pay_other: 0.0,
      remark: "",
      mch_ip: ""
    },
    search_name: "",
    headers_deposit: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "住院号", value: "pid" },
      { text: "交款时间", value: "pay_time" },
      { text: "收款人", value: "opcode" },
      { text: "本次预交金额", value: "pay_sum" },
      { text: "现金", value: "pay_cash" },
      { text: "微信", value: "pay_weixin" },
      { text: "支付宝", value: "pay_alipay" },
      { text: "银联", value: "pay_union" },
      { text: "支票", value: "pay_chk" },
      { text: "其他支付", value: "pay_other" },
      { text: "备注", value: "remark" },
      { text: "开户行", value: "bank" },
      { text: "帐号", value: "account" },
      { text: "支付状态", value: "pay_status" },
      { text: "住院科室", value: "dept_code" },
      { text: "病床号", value: "bed_nmb" },
      { text: "序号", value: "seq" }
    ],
    deposits_list: []
  }),
  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    this.deposit.opcode = this.topcode;
    getpatient_type(this.topcode, this.tgc).then(data => {
      this.patient_types = data;
    });
    getin_type(this.topcode, this.tgc).then(data => {
      this.in_types = data;
    });
    getdept_codes(this.topcode, this.tgc).then(data => {
      this.dept_codes = data;
    });
    getdeposit_list(10," ",this.topcode, this.tgc).then(data => {
      this.deposits_list = JSON.parse(data);
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
      console.log("tpid e=" + e);
      if (tpid.length < 10) {
        return;
      }
      //用在院患者登记信息填充预交金基本信息
      filldeposit(tpid, this.topcode, this.tgc).then(data => {
        console.log("data="+data)
        let tjson_obj = JSON.parse(data);
        this.deposit = tjson_obj;
        this.deposit.hsp_code = process.env.VUE_APP_HSP_CODE;
        this.deposit.pid = tpid;
        this.deposit.apply_opcode = this.topcode;
      });
    },
    schdeposit_listname(e){
      console.log("按姓名查询预交金记录" + e.innerText);
      let tname = this.search_name;
      if (tname.trim().length<1){
        console.log("按姓名查询,姓名不能为空");
        return;
      }else{
        getdeposit_list(99999, tname ,this.topcode, this.tgc).then(data => {
          this.deposits_list = JSON.parse(data);
       });
      }
    },
    select_deposit(item) {
      let tseq = item.seq;
      let tinstr = String(tseq);
      let turl = process.env.VUE_APP_INP_URL + "/searchdepositmulti/mkey/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_data_api(turl).then(data => {
        console.log("select_deposit data=" + data);
        let tjson_data = JSON.parse(data);
        this.deposit = tjson_data;
        this.deposit.hsp_code = process.env.VUE_APP_HSP_CODE;
        this.deposit.flow_nmb = "";
        this.deposit.invoice_nmb = "";
        this.deposit.apply_time = "";
        this.deposit.apply_opcode = this.topcode;
        this.deposit.pay_status = "N";
        this.deposit.pay_time = "";
        this.deposit.opcode = "";
        this.deposit.bank = "";
        this.deposit.deposit_cancel = "0";
        this.deposit.pay_source = "住院处窗口";
        this.deposit.account = "";
        this.deposit.pay_sum = 0.00;
        this.deposit.pay_cash = 0.00;
        this.deposit.pay_weixin = 0.00;
        this.deposit.pay_alipay = 0.00;
        this.deposit.pay_union = 0.00;
        this.deposit.pay_chk = 0.00;
        this.deposit.pay_other = 0.00;
        this.deposit.remark = "";
      });      
    },

    depositcash(e) {
      console.log("确认交款 e=" + e.target.innerText);
      let toutstr = "";
      let tjson_deposit = JSON.stringify(this.deposit);
      let tin_str = tjson_deposit + "|" + this.topcode + "|" +this.tgc;
      deposit4cash(tin_str).then(data => {
        let tjson_obj = JSON.parse(data)
        toutstr = tjson_obj.outdata;
        // this.valid_cashout = false;
        window.alert("预交金收款完成" + toutstr);
      });      
    }
   

    // ---------------------end methods----------------
  }
};
</script>

<style></style>