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
              <v-text-field v-model="admin_reg.pid_out" label="门诊号" @input="pidoutChanged($event)"> </v-text-field>
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
                @input="patient_typeChanged($event)"
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
            <v-flex d-flex>
               &emsp;&emsp;
              <v-text-field v-model="admin_reg.pid" label="住院号" disabled></v-text-field>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="admin_reg.pre_pay_sum" label="预交押金" class="title" suffix="元"></v-text-field>
            </v-flex>
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
                required
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.doctor_out"
                :items="doctor_codes"
                item-text="item-text"
                item-value="item-value"
                :rules="[v => !!v || '收治医生不能为空']"
                label="收治医生"
                hide-details
                prepend-icon="group_work"
                required
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-autocomplete
                v-model="admin_reg.diag_id"
                :loading="loading"
                :items="items_diag1"
                item-text="item-text"
                item-value="item-value"
                :search-input.sync="search_diag1"
                cache-items
                flat
                hide-no-data
                hide-details
                label="入院第一诊断"
                hint="请输入两个以上的诊断关键字"
              ></v-autocomplete>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-autocomplete
                v-model="admin_reg.diag_id2"
                :loading="loading"
                :items="items_diag2"
                item-text="item-text"
                item-value="item-value"
                :search-input.sync="search_diag2"
                cache-items
                flat
                hide-no-data
                hide-details
                label="入院第二诊断"
                hint="请输入两个以上的诊断关键字"
              ></v-autocomplete>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-autocomplete
                v-model="admin_reg.diag_id3"
                :loading="loading"
                :items="items_diag3"
                item-text="item-text"
                item-value="item-value"
                :search-input.sync="search_diag3"
                cache-items
                flat
                hide-no-data
                hide-details
                label="入院第三诊断"
                hint="请输入两个以上的诊断关键字"
              ></v-autocomplete>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.in_purpose"
                :items="in_purposes"
                item-text="item-text"
                item-value="item-value"
                label="入院原因"
                hide-details
                prepend-icon="group_work"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="admin_reg.in_status"
                :items="in_statuss"
                item-text="item-text"
                item-value="item-value"
                label="病情状态"
                hide-details
                prepend-icon="group_work"
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
                label="转入医院"
                hide-details
                prepend-icon="group_work"
                single-line
              ></v-select>
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
 <v-divider></v-divider>
    <v-spacer>&emsp;</v-spacer>
        <v-card-actions class="justify-center">
          <v-layout row wrap no-gutters>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
            <v-radio-group row v-model="pay_type">
              <v-flex d-flex><v-radio key="cash" label="现金" value="cash"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="wechat" label="微信" value="wechat"></v-radio></v-flex>
              <v-flex d-flex><v-radio key="alipay" label="支付宝" value="alipay"></v-radio></v-flex>
            </v-radio-group>

            <v-btn id="snap" :disabled="!valid" color="success" @click="capture">拍照</v-btn>
            <v-btn :disabled="!valid" color="success" :style="display_btn_readhealth">读健康卡</v-btn>
            <v-btn :disabled="!valid" color="success" v-on:click="readcardClicked($event)" :style="display_btn_readmi">读医保卡</v-btn>
            <v-btn :disabled="!valid" color="success" @click="admreg_save">确认入院</v-btn>
            <v-btn :disabled="valid" color="success" >打印预交金收据</v-btn>
            <v-btn :disabled="valid" color="success" @click="schweixinClicked($event)">
              查询微信订单
            </v-btn>
            <v-flex d-flex><v-spacer></v-spacer></v-flex>
          </v-layout>
        </v-card-actions>
      </v-card>
    </v-form>
 <v-divider></v-divider>
    <v-spacer>&emsp;</v-spacer>
    <canvas ref="canvas" id="canvas" width="640" height="480" hidden></canvas>
    <v-row no-gutters>
      <v-col cols="12" sm="12">
        <v-row no-gutters>
          <v-col><img v-bind:src="this.admin_reg_pic.pic1" height="240"/></v-col>
          <v-col><img v-bind:src="this.admin_reg_pic.pic2" height="240"/></v-col>
          <v-col><img v-bind:src="this.admin_reg_pic.pic3" height="240"/></v-col>
        </v-row>
        <v-row no-gutters>
          <v-col><img v-bind:src="this.admin_reg_pic.pic4" height="240"/></v-col>
          <v-col><img v-bind:src="this.admin_reg_pic.pic5" height="240"/></v-col>
          <v-col><img v-bind:src="this.admin_reg_pic.pic6" height="240"/></v-col>
        </v-row>
      </v-col>
    </v-row>
    <v-row no-gutters>
      <v-col cols="12" sm="12">
        <v-parallax
          height="700"
          dark
          :src="require('../assets/img/blank_cash.jpg')"
        >
          <div id="print_deposit">
            <v-card
              class="pa-2"
              outlined
              style="background-color: lightgrey;"
              tile
            >
              预交金收据打印样式
            </v-card>
          </div>
        </v-parallax>
      </v-col>
    </v-row>
    
    <v-card>
      <v-card-title>
        入院通知单列表
        <div class="flex-grow-1"></div>
      </v-card-title>
      <v-data-table :headers="headers_pat_retain" :items="tpat_retain_lists" item-key="seq" @click:row="select_pat_retain"> </v-data-table>
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
  getstreets,
  getin_status,
  getin_purpose,
  getdiag,
  getpatretain,
  filladminregbypid,
  save_adminreg,
  save_adminreg_pic
} from "../scripts/adm_reg.js";

export default {
  data: () => ({
    valid: true,
    topcode: "",
    tgc: "",
    nameRules: [v => !!v || "姓名不能为空", v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"],
    pay_type: "cash",
    patient_types: [], //患者类别列表
    genders: [], //性别列表
    idcard_types: [], //身份证件类型列表
    dept_codes: [], //就诊科室列表
    doctor_codes: [], //专家号专家列表
    addr_provs: [], //单位或住址(省份)
    addr_citys: [], //单位或住址(市)
    addr_countys: [], //单位或住址(区县)
    addr_townships: [], //单位或住址(街道)
    in_types: [], //入院医疗类别
    nations: [], //民族
    liaison_rels: [], //联系人关系,
    in_statuss: [], //入院病情状态
    in_purposes: [], //入院原因
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

    headers_pat_retain: [
      {
        text: "姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "门诊号", value: "pid" },
      { text: "申请时间", value: "retain_time" },
      { text: "申请医师", value: "retain_doctor" },
      { text: "门急诊诊断", value: "diag_name" },
      { text: "入院类别", value: "in_type" },
      { text: "患者类型", value: "patient_type" },
      { text: "通知单编号", value: "seq" }
    ],
    tpat_retain_lists: [],
    loading: false,
    items_diag1: [],
    items_diag2: [],
    items_diag3: [],
    search_diag1: null,
    search_diag2: null,
    search_diag3: null,
    display_btn_readhealth: "display:none",
    display_btn_readmi: "display:none",
  }),
  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    getpatient_type(this.topcode, this.tgc).then(data => {
      this.patient_types = data;
    });
    getgender(this.topcode, this.tgc).then(data => {
      this.genders = data;
    });
    getnation(this.topcode, this.tgc).then(data => {
      this.nations = data;
    });
    getin_type(this.topcode, this.tgc).then(data => {
      this.in_types = data;
    });
    getliaison_rels(this.topcode, this.tgc).then(data => {
      this.liaison_rels = data;
    });
    getdept_codes(this.topcode, this.tgc).then(data => {
      this.dept_codes = data;
    });
    getprovs(this.topcode, this.tgc).then(data => {
      this.addr_provs = data;
    });
    getcitys(process.env.VUE_APP_HSP_PROV, this.topcode, this.tgc).then(data => {
      this.addr_citys = data;
    });
    getcountys(process.env.VUE_APP_HSP_CITY, this.topcode, this.tgc).then(data => {
      this.addr_countys = data;
    });
    getstreets(process.env.VUE_APP_HSP_COUNTY, this.topcode, this.tgc).then(data => {
      this.addr_townships = data;
    });
    getin_purpose(this.topcode, this.tgc).then(data => {
      this.in_purposes = data;
    });
    getin_status(this.topcode, this.tgc).then(data => {
      this.in_statuss = data;
    });

    getpatretain(this.topcode, this.tgc).then(data => {
      this.tpat_retain_lists = JSON.parse(data);
    });

    this.video = this.$refs.video;
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia({ video: true }).then(stream => {
        this.video.srcObject = stream;
        this.video.play();
      });
    }
  },
  destroyed: function () {
    this.video.srcObject.getTracks()[0].stop(); //关闭摄像头
  },
  watch: {
    search_diag1(val) {
      val && val !== this.select && this.querySeldiag1s(val);
    },
    search_diag2(val) {
      val && val !== this.select && this.querySeldiag2s(val);
    },
    search_diag3(val) {
      val && val !== this.select && this.querySeldiag3s(val);
    }
  },
  // ----------------------------------------------------------------------
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
    querySeldiag1s(v) {
      this.loading = true;
      // console.log("v=" + v + "v.length=" + v.length);
      if (v.length < 2) {
        return;
      }
      getdiag(v, this.topcode, this.tgc).then(data => {
        this.items_diag1 = data;
      });
      this.loading = false;
    },
    querySeldiag2s(v) {
      this.loading = true;
      // console.log("v=" + v + "v.length=" + v.length);
      if (v.length < 2) {
        return;
      }
      getdiag(v, this.topcode, this.tgc).then(data => {
        this.items_diag2 = data;
      });
      this.loading = false;
    },
    querySeldiag3s(v) {
      this.loading = true;
      // console.log("v=" + v + "v.length=" + v.length);
      if (v.length < 2) {
        return;
      }
      getdiag(v, this.topcode, this.tgc).then(data => {
        this.items_diag3 = data;
      });
      this.loading = false;
    },
    pidoutChanged(e) {
      let tpid_out = e;
      console.log("tpid_out e=" + e);
      if (tpid_out.length < 12) {
        //门诊号必须12位
        return;
      }
      filladminregbypid(tpid_out, this.topcode, this.tgc).then(data => {
        console.log("data=" + data);
        let tjson_data = JSON.parse(data);
        this.admin_reg = tjson_data;
      });
    },
    select_pat_retain(item) {
      let tpid_out = item.pid;
      filladminregbypid(tpid_out, this.topcode, this.tgc).then(data => {
        console.log("select_pat_retain data=" + data);
        let tjson_data = JSON.parse(data);
        this.admin_reg = tjson_data;
      });      
    },
    //------------------医保类别医保1*读卡显示,农合2*显示读健康卡--------------
    patient_typeChanged(e) {
      let tptype = e;
      console.log("tptype e=" + tptype);
      this.display_btn_readmi = "display:none";
      this.display_btn_readhealth = "display:none";
      if (tptype.slice(0, 1) == "1") {
        //医保
        this.display_btn_readmi = "";
        this.isdisabled_patient_name = true;
      }
      if (tptype.slice(0, 1) == "2") {
        //农合
        this.display_btn_readhealth = "";
      }
    },
    readcardClicked(e) {
      console.log("e=" + e.target.innerText);
      //readcard_mi();
    },
    admreg_save() {
      console.log("确认入院登记");
      let tjson_adm_reg = JSON.stringify(this.admin_reg);
      let tin_str = tjson_adm_reg + "|" + this.topcode + "|" +this.tgc;
      // console.log("tin_str="+tin_str);
      save_adminreg(tin_str).then(data => {
        console.log("admreg_save data=" + data);
        let tjson_obj = JSON.parse(data);
        let tlist = Array.of();
        tlist = tjson_obj.outdata.split("|");
        console.log("-----tlist[0]=" + tlist[0]+ "   tlist[1]=" +tlist[1]);
        if (tlist[0]<0){
          window.alert("入院登记失败:" + tlist[1]);
        }else{
          this.admin_reg.pid = tlist[0];
          this.admin_reg_pic.pid = this.admin_reg.pid;
          this.admin_reg_pic.ex_pid = this.admin_reg.ex_pid;
          this.admin_reg_pic.patient_name = this.admin_reg.patient_name;
          this.admin_reg_pic.idcard = this.admin_reg.idcard;
          this.admin_reg_pic.health_id = this.admin_reg.health_id;
          this.admin_reg_pic.micard = this.admin_reg.micard;
          this.admin_reg_pic.capture_time = this.admin_reg.in_time;
          this.admin_reg_pic.capture_opid = this.admin_reg.opcode;
          // -------------------保存照片----------------------------------------------
          this.admin_reg_pic.topcode = this.topcode;
          this.admin_reg_pic.tgc = this.tgc;
          let tjson_adm_reg_pic = JSON.stringify(this.admin_reg_pic);
          console.log("tjson_adm_reg_pic=" + tjson_adm_reg_pic);
          save_adminreg_pic(tjson_adm_reg_pic).then(data => {
            console.log("admreg_pic_save data=" + data);
          });
          window.alert("入院登记完成,新住医院号:" + tlist[0] + "请打印预交金收据");
        }
      
      });
      
    },
    schweixinClicked(e) {
      console.log("e=" + e.target.innerText);
      //sch_weixin();
    },
    dept_codeChanged(e) {
      let tdept_code = this.admin_reg.dept_code;
      console.log("dept_codeChanged e=" + e);
      let tpost_tech = "1";
      getdoctor_codes(tdept_code, tpost_tech, this.topcode, this.tgc).then(data => {
        this.doctor_codes = data;
      });
    },
    //------------------获取指定省份的市列表---------------------------
    prov_Changed() {
      let tprovid = this.admin_reg.addr_prov;
      console.log("tprovid="+tprovid)
      getcitys(tprovid, this.topcode, this.tgc).then(data => {
        this.addr_citys = data;
      });
    },
    //------------------获取指定市的区县列表---------------------------
    city_Changed() {
      let tcityid = this.admin_reg.addr_city;
      getcountys(tcityid, this.topcode, this.tgc).then(data => {
        this.addr_countys = data;
      });
    },
    //------------------获取指定区县的街道列表---------------------------
    county_Changed() {
      let tcountyid = this.admin_reg.addr_county;
      getstreets(tcountyid, this.topcode, this.tgc).then(data => {
        this.addr_townships = data;
      });
    },
    capture() {
      this.canvas = this.$refs.canvas;
      var ctx = this.canvas.getContext("2d");
      //console.log(this.$refs.canvas.toDataURL("image/png"));
      ctx.drawImage(this.video, 0, 0, 640, 480);
      //this.captures.push(this.$refs.canvas.toDataURL("image/png"));
      switch (this.capture_num) {
        case 0:
          this.admin_reg_pic.pic1 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        case 1:
          this.admin_reg_pic.pic2 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        case 2:
          this.admin_reg_pic.pic3 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        case 3:
          this.admin_reg_pic.pic4 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        case 4:
          this.admin_reg_pic.pic5 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        case 5:
          this.admin_reg_pic.pic6 = this.$refs.canvas.toDataURL("image/png",0.1);
          this.capture_num++;
          break;
        default:
          this.capture_num = 0;
          this.admin_reg_pic.pic1 = this.$refs.canvas.toDataURL("image/png",0.1);
      }
      //--
    }
    // ---------------------end methods----------------
  }
};
</script>

<style></style>
