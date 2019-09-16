<template>
  <v-container class="grey lighten-5">
    <v-form ref="form" v-model="valid" lazy-validation>
      <v-card class="mx-auto" max-width="99%" min-width="100%">
        <v-img
          class="white--text"
          height="60px"
          :src="require('../assets/outreg.jpg')"
        >
          <v-card-title class="align-end fill-height">补预交金</v-card-title>
        </v-img>
        <v-card-text>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field
                v-model="out_reg.exPid"
                label="住院号"
                @input="expidChanged($event)"
              >
              </v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field
                v-model="out_reg.patientName"
                label="患者姓名"
                readonly
              ></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="out_reg.patientType"
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
                v-model="out_reg.patientType"
                label="医疗类别"
                readonly
                :items="patient_types"
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
              <v-text-field
                v-model="out_reg.idcard" readonly
                label="身份证号"                
              ></v-text-field
              >&emsp;&emsp;
            </v-flex>          
            <v-flex d-flex>
              <v-text-field
                v-model="out_reg.pid"
                label="患者主索引"
                readonly
              ></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field
                v-model="out_reg.idcard"
                label="联系电话" readonly  
              ></v-text-field
              >&emsp;&emsp;
            </v-flex>
                
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="out_reg.deptCode"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="住院科室"
                hide-details
                prepend-icon="group_work"
                single-line
                readonly
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="out_reg.deptCode"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="主管医生"
                hide-details
                prepend-icon="group_work"
                single-line
                readonly
              ></v-select>
            </v-flex>        
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field
                v-model="out_reg.addrHouseNmb"
                label="补交押金"
                suffix="元"
              ></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field
                v-model="out_reg.addrHouseNmb"
                label="备注"
              ></v-text-field>
            </v-flex>
          </v-layout>
          <!-- <v-spacer></v-spacer>           -->         
        </v-card-text>
        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="payType">
            <v-flex d-flex
              ><v-radio key="cash" label="现金" value="cash"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="wechat" label="微信" value="wechat"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="alipay" label="支付宝" value="alipay"></v-radio
            ></v-flex>
          </v-radio-group>
          <v-btn :disabled="!valid" color="success" @click="validate"
            >查询</v-btn
          >         
          <v-btn
            :disabled="!valid"
            color="success"
            @click="outregcashClicked($event)"
            >确认补交</v-btn
          >      
          <v-btn
            :disabled="!valid"
            color="success"
            @click="schweixinClicked($event)"
          >
            查询微信订单
          </v-btn>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>
        </v-card-actions>
      </v-card>
      

    </v-form>
    
 
<v-card>
    <v-card-title>
      患者预交金明细表
      <div class="flex-grow-1"></div>
      <v-text-field
        v-model="search"
        append-icon="search"
        label="按姓名查询"
        single-line
        hide-details
      ></v-text-field>
    </v-card-title>
    <v-data-table
      :headers="headers"
      :items="desserts"
      :search="search"
    ></v-data-table>
  </v-card>
    <v-row>
          <v-col>
            <v-card
              class="pa-2"
              outlined
              style="background-color: lightgrey;"
              tile
            >
              预交金收据打印样式
            </v-card>
          </v-col>
        </v-row>
  </v-container>
</template>
<script>
import {
  getpatient_type,
  get_regopcode,
  getgender,
  getid_type,
  getreg_type,
  getdept_codes,
  getdoctor_codes,
  getprovs,
  getcitys,
  getcountys,
  getstreets,
  getpatient,
  readcard_mi,
  outreg_cash,
  outreg_weixin,
  outreg_pic,
  sch_weixin,
  getregprice
} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    nameRules: [
      v => !!v || "姓名不能为空",
      v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"
    ],
    //barcodeRules: [
    //  v => !!v || "条形码不能为空",
    //  v => (v && v.length >= 13) || "条形码应该为13位数字"
    //],
    patient_types: [], //患者类别列表
    genders: [], //性别列表
    idcard_types: [], //身份证件类型列表
    dept_codes: [], //就诊科室列表
    doctor_codes: [], //专家号专家列表
    reg_types: [], //挂号类别
    addr_provs: [], //单位或住址(省份)
    addr_citys: [], //单位或住址(市)
    addr_countys: [], //单位或住址(区县)
    addr_townships: [], //单位或住址(街道)
    out_reg: {
      hspCode: process.env.VUE_APP_HSP_CODE,
      pid: "", //门诊号
      pidType: "O", //患者标识类别
      exPid: "", //条形码
      patientName: "", //患者姓名
      gender: "", //性别代码
      ageY: "", // 年龄
      ageM: "", //  年龄
      ageD: "", //  年龄
      patientType: "", //患者类型
      regType: "pz", // 挂号类别
      regPrice: 0.0, //挂号费
      checkPrice: 0.0, //诊察费
      visitPriority: "0", //就诊优先标志
      deptCode: "", //就诊科室
      doctorCode: "", //门诊接诊医生
      idcard: "", //患者身份证号码
      idcardType: "jmsfz", //患者身份证件类别
      addrProv: process.env.VUE_APP_HSP_PROV, //地址
      addrCity: process.env.VUE_APP_HSP_CITY,
      addrCounty: process.env.VUE_APP_HSP_COUNTY,
      addrTownship: "",
      addrStreet: "",
      addrHouseNmb: "",
      miPaccLeft: 0.0,
      miCompany: "",
      miStr: "",
      miType: "",
      micard: "",
      payType: "",
      regOpcode: "", //挂号员
      payCash: 0.0, //现金支付金额
      payPacc: 0.0, //医保(农合)个人帐户支付金额
      payFund: 0.0, //医保(农合)统筹支付金额
      payNfc: 0.0, //移动支付金额
      invoiceNmb: "", //挂号单收据流水号
      flowNmb: "", //挂号单操作员流水号
      mchIp: "", //本机局域网IP地址
      ver: process.env.VUE_APP_VERSION //版本号
    },
    video: {},
    canvas: {},
    //captures: [],
    capture_num: 0,
    out_reg_pic: {
      hspCode: process.env.VUE_APP_HSP_CODE,
      pid: "",
      exPid: "",
      patientName: "",
      idcard: "",
      healthId: "",
      micard: "",
      captureTime: "",
      captureOpid: "",
      mchIp: "",
      pic1: "",
      pic2: "",
      pic3: "",
      pic4: "",
      pic5: "",
      pic6: ""
    },
    search: '',
        headers: [
          {
            text: '姓名',
            align: 'left',
            sortable: false,
            value: 'name',
          },
          { text: '门诊号', value: 'calories' },
          { text: '申请时间', value: 'fat' },
          { text: '申请医师', value: 'carbs' },
          { text: '门急诊诊断', value: 'protein' },
          { text: '患者类型', value: 'iron' },
        ],
        desserts: [
          {
            name: 'Frozen Yogurt',
            calories: 159,
            fat: 6.0,
            carbs: 24,
            protein: 4.0,
            iron: '1%',
          },
          {
            name: 'Ice cream sandwich',
            calories: 237,
            fat: 9.0,
            carbs: 37,
            protein: 4.3,
            iron: '1%',
          },
          {
            name: 'Eclair',
            calories: 262,
            fat: 16.0,
            carbs: 23,
            protein: 6.0,
            iron: '7%',
          },
          {
            name: 'Cupcake',
            calories: 305,
            fat: 3.7,
            carbs: 67,
            protein: 4.3,
            iron: '8%',
          },
          {
            name: 'Gingerbread',
            calories: 356,
            fat: 16.0,
            carbs: 49,
            protein: 3.9,
            iron: '16%',
          },
          {
            name: 'Jelly bean',
            calories: 375,
            fat: 0.0,
            carbs: 94,
            protein: 0.0,
            iron: '0%',
          },
          {
            name: 'Lollipop',
            calories: 392,
            fat: 0.2,
            carbs: 98,
            protein: 0,
            iron: '2%',
          },
          {
            name: 'Honeycomb',
            calories: 408,
            fat: 3.2,
            carbs: 87,
            protein: 6.5,
            iron: '45%',
          },
          {
            name: 'Donut',
            calories: 452,
            fat: 25.0,
            carbs: 51,
            protein: 4.9,
            iron: '22%',
          },
          {
            name: 'KitKat',
            calories: 518,
            fat: 26.0,
            carbs: 65,
            protein: 7,
            iron: '6%',
          },
        ]

  }),
  created() {
    this.out_reg.regOpcode = get_regopcode();
    this.patient_types = getpatient_type();
    this.genders = getgender();
    this.idcard_types = getid_type();
    this.reg_types = getreg_type();
    this.dept_codes = getdept_codes();
    this.addr_provs = getprovs();
    this.addr_citys = getcitys(process.env.VUE_APP_HSP_PROV);
    this.addr_countys = getcountys(process.env.VUE_APP_HSP_CITY);
    this.addr_townships = getstreets(process.env.VUE_APP_HSP_COUNTY);
  },
  mounted() {
    this.video = this.$refs.video;
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia({ video: true }).then(stream => {
        this.video.srcObject = stream;
        this.video.play();
      });
    }
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
      if (texpid.length<10){
        return;
      }
      getpatient(texpid).then(data => {
        this.out_reg = data;
      });
    },
    readcardClicked(e) {
      console.log("e=" + e.target.innerText);
      readcard_mi();
    },
    outregcashClicked(e) {
      console.log("e=" + e.target.innerText);
      outreg_cash(this.out_reg).then(data =>{
        this.out_reg.pid = data;
        console.log("outregcashClicked this.out_reg_pic.pid=" +this.out_reg_pic.pid);
        this.out_reg_pic.pid = this.out_reg.pid;
        this.out_reg_pic.exPid = this.out_reg.exPid;
        this.out_reg_pic.patientName = this.out_reg.patientName;
        this.out_reg_pic.idcard = this.out_reg.idcard;
        this.out_reg_pic.healthId = this.out_reg.healthId;
        this.out_reg_pic.micard = this.out_reg.micard;
        this.out_reg_pic.captureOpid = this.out_reg.regOpcode;
        outreg_pic(this.out_reg_pic);
      });
      
    },
    outregweixinClicked(e) {
      console.log("e=" + e.target.innerText);
      outreg_weixin();
    },
    schweixinClicked(e) {
      console.log("e=" + e.target.innerText);
      sch_weixin();
    },
    dept_codeChanged(e) {
      let tdept_code = this.out_reg.deptCode;
      console.log("dept_codeChanged e=" + e);
      let tpost_tech = "1";
      this.doctor_codes = getdoctor_codes(tdept_code, tpost_tech);
    },
    reg_typeChanged(e) {
      console.log("reg_typeChanged e=" + e);
      let treg_type = this.out_reg.regType;
      getregprice(treg_type).then(data => {
        this.out_reg.regPrice = data[0];
        this.out_reg.checkPrice = data[1];
      });
    },
    //------------------获取指定省份的市列表---------------------------
    prov_Changed() {
      let tprovid = this.out_reg.addrProv;
      this.addr_citys = getcitys(tprovid);
    },
    //------------------获取指定市的区县列表---------------------------
    city_Changed() {
      let tcityid = this.out_reg.addrCity;
      this.addr_countys = getcountys(tcityid);
    },
    //------------------获取指定区县的街道列表---------------------------
    county_Changed() {
      let tcountyid = this.out_reg.addrCounty;
      this.addr_townships = getstreets(tcountyid);
    },
    capture() {
      this.canvas = this.$refs.canvas;
      var ctx = this.canvas.getContext("2d");
      //console.log(this.$refs.canvas.toDataURL("image/png"));
      ctx.drawImage(this.video, 0, 0, 640, 480);
      //this.captures.push(this.$refs.canvas.toDataURL("image/png"));
      switch (this.capture_num) {
        case 0:
          this.out_reg_pic.pic1 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        case 1:
          this.out_reg_pic.pic2 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        case 2:
          this.out_reg_pic.pic3 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        case 3:
          this.out_reg_pic.pic4 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        case 4:
          this.out_reg_pic.pic5 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        case 5:
          this.out_reg_pic.pic6 = this.$refs.canvas.toDataURL("image/png");
          this.capture_num++;
          break;
        default:
          this.capture_num = 0;
          this.out_reg_pic.pic1 = this.$refs.canvas.toDataURL("image/png");
      }
      //--
    }
    // ---------------------end methods----------------
  }
};
</script>

<style></style>
