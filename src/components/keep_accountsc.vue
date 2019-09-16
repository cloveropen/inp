<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.pid"
              label="门诊号"
              @input="getfeedetail($event)"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patientName"
              label="姓名"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.regType"
              label="就诊类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patientType"
              label="患者类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.miPaccLeft"
              label="医保卡余额"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.outDiag"
              label="门诊诊断"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.addr"
              label="住址"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>
    </v-card>
    <div>
   <v-toolbar
    dark
    color="teal"
  >
    <v-toolbar-title>选择收费项目</v-toolbar-title>
    <v-autocomplete
      v-model="select"
      :loading="loading"
      :items="items"
      :search-input.sync="search"
      cache-items
      class="mx-4"
      flat
      hide-no-data
      hide-details
      label="补收收费项目"
      solo-inverted
    ></v-autocomplete>
    <v-btn icon>
      <v-icon>mdi-dots-vertical</v-icon>
    </v-btn>
     <v-text-field
            v-model="firstname"
            label="数量"
            required
      ></v-text-field>
  </v-toolbar>
  </div>
    <!--------------------------结算信息栏----------------------------------------------- -->
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.payShould"
              label="应收金额"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payCash"
              label="现金支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payNfc"
              label="移动支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payPacc"
              label="医保帐户"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payFund"
              label="医保统筹"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          
          <v-flex d-flex          
            ><v-spacer></v-spacer>
            <v-btn id="snap" :disabled="!valid" color="success">预 结 算</v-btn>
            <v-btn :disabled="!valid" color="success" @click="validate"
              >新增费用</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >确认记帐</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >查询明细</v-btn
            >          
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
    <v-data-table
      :headers="headers"
      :items="fee_details"
       :items-per-page="10"
        class="elevation-1"
    ></v-data-table>
  </v-card>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    valid: true,
    nameRules: [
      v => !!v || "姓名不能为空",
      v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"
    ],
   loading: false,
        items: [],
        search: null,
        select: null,
        states: [
          'Alabama',
          'Alaska',
          'American Samoa',
          'Arizona',
          'Arkansas',
          'California',
          'Colorado',
          'Connecticut',
          'Delaware',
          'District of Columbia',
          'Federated States of Micronesia',
          'Florida',
          'Georgia',
          'Guam',
          'Hawaii',
          'Idaho',
          'Illinois',
          'Indiana',
          'Iowa',
          'Kansas',
          'Kentucky',
          'Louisiana',
          'Maine',
          'Marshall Islands',
          'Maryland',
          'Massachusetts',
          'Michigan',
          'Minnesota',
          'Mississippi',
          'Missouri',
          'Montana',
          'Nebraska',
          'Nevada',
          'New Hampshire',
          'New Jersey',
          'New Mexico',
          'New York',
          'North Carolina',
          'North Dakota',
          'Northern Mariana Islands',
          'Ohio',
          'Oklahoma',
          'Oregon',
          'Palau',
          'Pennsylvania',
          'Puerto Rico',
          'Rhode Island',
          'South Carolina',
          'South Dakota',
          'Tennessee',
          'Texas',
          'Utah',
          'Vermont',
          'Virgin Island',
          'Virginia',
          'Washington',
          'West Virginia',
          'Wisconsin',
          'Wyoming',
        ],
    out_reg: {
      seq: 0,
      hspCode: process.env.VUE_APP_HSP_CODE,
      pid: "", //门诊号
      patientName: "",
      patientType: "",
      regType: "",
      prescNmb: "",
      outDiag: "", //门诊诊断
      miPaccLeft: 0.0, //医保卡余额
      addr: "", //住址
      payShould: 0.0, //应收金额
      payCash: 0.0, //实收现金
      payNfc: 0.0, //移动支付
      payPacc: 0.0, //医保帐户
      payFund: 0.0 //医保统筹      
    },
    payType: "cash", //支付方式选择
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
    console.log("created");
  },
  mounted() {
    console.log("mounted");
  },
   watch: {
      search (val) {
        val && val !== this.select && this.querySelections(val)
      },
    },
  methods: {
    querySelections (v) {
        this.loading = true
        // Simulated ajax query
        setTimeout(() => {
          this.items = this.states.filter(e => {
            return (e || '').toLowerCase().indexOf((v || '').toLowerCase()) > -1
          })
          this.loading = false
        }, 500)
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
      //门诊号规则:患者主索引8位，门诊号为11位，门诊号=主索引编号+3位数字，后3位数字为挂号的序号
      let tpid = e.trim();
      let _this = this;
      if (tpid.length == 8 || tpid.length == 11) {
        let thsp_code = process.env.VUE_APP_HSP_CODE;
        fetch(
          process.env.VUE_APP_REG_URL +
            "/searchoutregcash/" +
            tpid +
            "/" +
            thsp_code,
          {
            method: "get",
            headers: {
              Accept: "text/html",
              "Content-Type": "application/json"
            }
          }
        )
          .then(function(response) {
            if (response.ok) {
              //window.alert("---ok=");
            } else {
              window.alert("查询患者信息失败error" + response.text);
            }
            return response.json();
          })
          .then(function(data) {
            console.log("data="+JSON.stringify(data))
            let tresultCode = data.resultCode;
            //window.alert("tresultCode="+tresultCode)
            if (tresultCode === "0") {
              _this.out_reg = JSON.parse(data.outdata);
              console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
              console.log(" this.out_reg.patientName=" + _this.out_reg.patientName);
              //return toutreg;
            } else {
              window.alert("查询患者主索引信息失败1" + data.errorMsg);
            }
          })
          .catch(function(err) {
            window.alert("查询患者主索引信息查询error=" + err);
          });
      } else {
        //window.alert("请输入正确的门诊号或患者主索引号");
        return;
      }
      console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
      return _this.out_reg;
    },
    getfeedetail(e){
      console.log("getfeedetail pid=" + e);
      //门诊号规则:患者主索引8位，门诊号为11位，门诊号=主索引编号+3位数字，后3位数字为挂号的序号
      let tpid = e.trim();
      let _this = this;
      if (tpid.length == 8 || tpid.length == 11) {
        let thsp_code = process.env.VUE_APP_HSP_CODE;
        fetch(
          process.env.VUE_APP_REG_URL +
            "/searchfeedetail/" +
            tpid +
            "/9/" +
            thsp_code,
          {
            method: "get",
            headers: {
              Accept: "text/html",
              "Content-Type": "application/json"
            }
          }
        )
          .then(function(response) {
            if (response.ok) {
              //window.alert("---ok=");
            } else {
              window.alert("查询患者信息失败error" + response.text);
            }
            return response.json();
          })
          .then(function(data) {
            console.log("data="+JSON.stringify(data))
            let tresultCode = data.resultCode;
            //window.alert("tresultCode="+tresultCode)
            if (tresultCode === "0") {
              _this.fee_details = JSON.parse(data.outdata);
              console.log(" this.out_reg=" + JSON.stringify(_this.fee_details));          
            } else {
              window.alert("查询患者主索引信息失败1" + data.errorMsg);
            }
          })
          .catch(function(err) {
            window.alert("查询患者主索引信息查询error=" + err);
          });
      } else {
        //window.alert("请输入正确的门诊号或患者主索引号");
        return;
      }
      console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
      return _this.out_reg;
    }
    // ---------------------end methods----------------
  }
};
</script>
