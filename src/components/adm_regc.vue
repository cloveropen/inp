<template>
  <v-container class="grey lighten-5">
    <v-form ref="form" v-model="valid" lazy-validation>
      <v-card class="mx-auto" max-width="99%" min-width="100%">
        <v-img class="white--text" height="60px" :src="require('../assets/outreg.jpg')">
          <v-card-title class="align-end fill-height">入院登记</v-card-title>
        </v-img>
        <v-card-text>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field v-model="admin_reg.pid_out" label="门诊号" @input="expidChanged($event)"> </v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.patient_name" label="患者姓名" required :counter="6" :rules="nameRules"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.patient_type"
                label="患者类型"
                required
                :items="patient_types"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '患者类型不能为空']"
                hide-details
                prepend-icon="map"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.in_type"
                label="医疗类别"
                required
                :items="in_types"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '患者入院医疗类别不能为空']"
                hide-details
                prepend-icon="map"
                single-line
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.gender"
                :items="genders"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '患者性别不能为空']"
                label="性别"
                hide-details
                prepend-icon="map"
                required
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.idcard" label="身份证号"></v-text-field>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select v-model="admin_reg.nation" :items="nations" item-text="item-text" item-value="item-value" label="民族" hide-details></v-select>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field v-model="admin_reg.pid" label="住院号" disabled></v-text-field>
            </v-flex>
            &emsp;&emsp;
            <!-- <v-flex d-flex>
              <v-text-field
                v-model="admin_reg.ex_pid"
                label="患者主索引"
                disabled
              ></v-text-field>
            </v-flex> -->
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.tel" label="联系电话"></v-text-field>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.age_y" label="年龄(岁)"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.age_m" label="年龄(月)"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.age_d" label="年龄(天)"></v-text-field>&emsp;&emsp;
            </v-flex>

            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.addr_prov"
                :items="addr_provs"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '住址省份不能为空']"
                label="住址(省份)"
                hide-details
                prepend-icon="group_work"
                required
                @input="prov_Changed"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.addr_city"
                :items="addr_citys"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '住址-市不能为空']"
                label="住址(市)"
                hide-details
                prepend-icon="group_work"
                required
                @input="city_Changed"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.addr_county"
                :items="addr_countys"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '住址-区县不能为空']"
                label="住址(区县)"
                hide-details
                prepend-icon="group_work"
                required
                @input="county_Changed"
              ></v-select
              >&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.addr_township"
                :items="addr_townships"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '住址-街道社区不能为空']"
                label="住址(街道社区)"
                hide-details
                prepend-icon="group_work"
                required
              ></v-select
              >&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.addr_house_nmb" label="住址(详细地址)"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.liaison" label="联系人"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.liaison_rel"
                :items="liaison_rels"
                item-text="item-text"
                item-value="item-value"
                label="与患者关系"
                hide-details
                prepend-icon="map"
              ></v-select
              >&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.liaison_tel" label="联系人电话"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.dept_code"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '入院科室不能为空']"
                label="住院科室"
                hide-details
                prepend-icon="group_work"
                single-line
                required
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.doctor_out"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '收治医生不能为空']"
                label="收治医生"
                hide-details
                prepend-icon="group_work"
                single-line
                required
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.diag_id"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '入院诊断']"
                label="入院诊断"
                hide-details
                prepend-icon="group_work"
                single-line
                required
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.diag_id2"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="入院第二诊断"
                hide-details
                prepend-icon="group_work"
                single-line
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.diag_id3"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="入院第三诊断"
                hide-details
                prepend-icon="group_work"
                single-line
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.in_purpose"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="入院原因"
                hide-details
                prepend-icon="group_work"
                single-line
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.in_status"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="病情状态"
                hide-details
                prepend-icon="group_work"
                single-line
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-checkbox v-model="admin_reg.hbsag_flag" label="HBsAg"></v-checkbox>
              &emsp;&emsp;
              <v-checkbox v-model="admin_reg.hcv_flag" label="HCV"></v-checkbox>
              &emsp;&emsp;
              <v-checkbox v-model="admin_reg.hiv_flag" label="HIV"></v-checkbox>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.out_hsp"
                :items="dept_codes"
                item-text="item-text"
                item-value="item-value"
                label="上一医院"
                hide-details
                prepend-icon="group_work"
                single-line
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.pre_pay_sum" label="预交押金" suffix="元"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.remark" label="备注"></v-text-field>
            </v-flex>
          </v-layout>
          <!-- <v-spacer></v-spacer>           -->

          <v-row>
            <v-col sm="12">
              <!-- <v-card class="pa-2" outlined tile>就诊人信息</v-card> -->
              <v-row no-gutters>
                <v-col cols="6" sm="7">
                  <v-card class="pa-4" elevation="18">
                    <div>
                      <video ref="video" id="video" width="640" height="480" autoplay></video>
                    </div>
                  </v-card>
                </v-col>
                <v-col cols="6" sm="5">
                  <v-card class="pa-4" elevation="18" tile>
                    <v-row>
                      <v-col cols="12">
                        <div class="title">患者医保信息</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保个人编号:{{ admin_reg.micard }}</div>
                      </v-col>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保卡余额:{{ admin_reg.mi_pacc_left }}</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保类别:{{ admin_reg.mi_type }}</div>
                      </v-col>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;参保单位:{{ admin_reg.mi_company }}</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <div class="subtitle-1">&emsp;&emsp;读卡信息:{{ admin_reg.mi_str }}</div>
                      </v-col>
                    </v-row>
                  </v-card>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
            <v-radio-group row v-model="pay_type">
              <v-flex d-flex><v-radio key="cash" label="现金" value="cash"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="wechat" label="微信" value="wechat"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="alipay" label="支付宝" value="alipay"></v-radio></v-flex>
            </v-radio-group>

            <v-btn id="snap" :disabled="!valid" color="success" @click="capture">拍照</v-btn>
            <v-btn :disabled="!valid" color="success" @click="validate">读健康卡</v-btn>
            <v-btn :disabled="!valid" color="success" v-on:click="readcardClicked($event)">读医保卡</v-btn>
            <v-btn :disabled="!valid" color="success" @click="outregcashClicked($event)">确认入院</v-btn>
            <v-btn :disabled="!valid" color="success" @click="schweixinClicked($event)">
              查询微信订单
            </v-btn>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>
        </v-card-actions>
      </v-card>
    </v-form>
    <canvas ref="canvas" id="canvas" width="640" height="480" hidden></canvas>
    <!-- <ul>
      <v-list v-for="c in captures" :key="c">
        <img v-bind:src="c" height="180" />
      </v-list>
    </ul> -->

    <v-row>
      <v-col sm="12">
        <!--  第二级 -->
        <v-row no-gutters>
          <v-col cols="8" sm="6">
            <!-- 第三级 显示照片 -->
            <v-row no-gutters>
              <v-col><img v-bind:src="this.admin_reg_pic.pic1" height="120"/></v-col>
              <v-col><img v-bind:src="this.admin_reg_pic.pic2" height="120"/></v-col>
              <v-col><img v-bind:src="this.admin_reg_pic.pic3" height="120"/></v-col>
            </v-row>
            <v-row no-gutters>
              <v-col><img v-bind:src="this.admin_reg_pic.pic4" height="120"/></v-col>
              <v-col><img v-bind:src="this.admin_reg_pic.pic5" height="120"/></v-col>
              <v-col><img v-bind:src="this.admin_reg_pic.pic6" height="120"/></v-col>
            </v-row>
          </v-col>
          <v-col cols="4" sm="6">
            <v-card class="pa-2" outlined style="background-color: lightgrey;" tile>
              预交金收据打印样式
            </v-card>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <v-card>
      <v-card-title>
        入院通知单列表
        <div class="flex-grow-1"></div>
        <v-text-field v-model="search" append-icon="search" label="按姓名查询" single-line hide-details></v-text-field>
      </v-card-title>
      <v-data-table :headers="headers" :items="desserts" :search="search"></v-data-table>
    </v-card>
  </v-container>
</template>
<script>
import {
  getpatient_type,
  get_regopcode,
  getgender,
  getnation,
  getin_type,
  getliaison_rels,
  getdept_codes,
  getdoctor_codes,
  getprovs,
  getcitys,
  getcountys,
  getstreets
} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    nameRules: [v => !!v || "姓名不能为空", v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"],
    //barcodeRules: [
    //  v => !!v || "条形码不能为空",
    //  v => (v && v.length >= 13) || "条形码应该为13位数字"
    //],
    pay_type: "cash",
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
    in_types: [], //入院医疗类别
    nations: [], //民族
    liaison_rels: [], //联系人关系
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
    admin_reg_pic: {
      hsp_code: process.env.VUE_APP_HSP_CODE,
      pid: "",
      ex_pid: "",
      patient_name: "",
      idcard: "",
      health_id: "",
      micard: "",
      capture_time: "",
      capture_opid: "",
      mch_ip: "",
      pic1: "",
      pic2: "",
      pic3: "",
      pic4: "",
      pic5: "",
      pic6: ""
    },
    video: {},
    canvas: {},
    //captures: [],
    capture_num: 0,

    search: "",
    headers: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "name"
      },
      { text: "门诊号", value: "calories" },
      { text: "申请时间", value: "fat" },
      { text: "申请医师", value: "carbs" },
      { text: "门急诊诊断", value: "protein" },
      { text: "患者类型", value: "iron" }
    ],
    desserts: [
      {
        name: "Frozen Yogurt",
        calories: 159,
        fat: 6.0,
        carbs: 24,
        protein: 4.0,
        iron: "1%"
      },
      {
        name: "Ice cream sandwich",
        calories: 237,
        fat: 9.0,
        carbs: 37,
        protein: 4.3,
        iron: "1%"
      },
      {
        name: "Eclair",
        calories: 262,
        fat: 16.0,
        carbs: 23,
        protein: 6.0,
        iron: "7%"
      },
      {
        name: "Cupcake",
        calories: 305,
        fat: 3.7,
        carbs: 67,
        protein: 4.3,
        iron: "8%"
      },
      {
        name: "Gingerbread",
        calories: 356,
        fat: 16.0,
        carbs: 49,
        protein: 3.9,
        iron: "16%"
      },
      {
        name: "Jelly bean",
        calories: 375,
        fat: 0.0,
        carbs: 94,
        protein: 0.0,
        iron: "0%"
      },
      {
        name: "Lollipop",
        calories: 392,
        fat: 0.2,
        carbs: 98,
        protein: 0,
        iron: "2%"
      },
      {
        name: "Honeycomb",
        calories: 408,
        fat: 3.2,
        carbs: 87,
        protein: 6.5,
        iron: "45%"
      },
      {
        name: "Donut",
        calories: 452,
        fat: 25.0,
        carbs: 51,
        protein: 4.9,
        iron: "22%"
      },
      {
        name: "KitKat",
        calories: 518,
        fat: 26.0,
        carbs: 65,
        protein: 7,
        iron: "6%"
      }
    ]
  }),
  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
    console.log("this.topcode=" + this.topcode + " this.tgc=" + this.tgc);
  },
  mounted() {
    this.patient_types = getpatient_type(this.topcode, this.tgc);
    this.genders = getgender(this.topcode, this.tgc);
    this.nations = getnation(this.topcode, this.tgc);
    this.in_types = getin_type(this.topcode, this.tgc);
    this.liaison_rels = getliaison_rels(this.topcode, this.tgc);
    this.dept_codes = getdept_codes(this.topcode, this.tgc);
    this.addr_provs = getprovs(this.topcode, this.tgc);
    this.addr_citys = getcitys(process.env.VUE_APP_HSP_PROV, this.topcode, this.tgc);
    this.addr_countys = getcountys(process.env.VUE_APP_HSP_CITY, this.topcode, this.tgc);
    this.addr_townships = getstreets(process.env.VUE_APP_HSP_COUNTY, this.topcode, this.tgc);

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
      if (texpid.length < 10) {
        return;
      }
      //getpatient(texpid).then(data => {
      //  this.out_reg = data;
      //});
    },
    readcardClicked(e) {
      console.log("e=" + e.target.innerText);
      //readcard_mi();
    },

    outregweixinClicked(e) {
      console.log("e=" + e.target.innerText);
      //outreg_weixin();
    },
    schweixinClicked(e) {
      console.log("e=" + e.target.innerText);
      //sch_weixin();
    },
    dept_codeChanged(e) {
      let tdept_code = this.out_reg.deptCode;
      console.log("dept_codeChanged e=" + e);
      let tpost_tech = "1";
      this.doctor_codes = getdoctor_codes(tdept_code, tpost_tech);
    },
    reg_typeChanged(e) {
      console.log("reg_typeChanged e=" + e);
      /*let treg_type = this.out_reg.regType;
      getregprice(treg_type).then(data => {
        this.out_reg.regPrice = data[0];
        this.out_reg.checkPrice = data[1];
      });*/
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
