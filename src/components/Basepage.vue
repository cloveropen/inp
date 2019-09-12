<template>
  <div>
    <v-navigation-drawer
      v-model="drawer"
      :clipped="$vuetify.breakpoint.lgAndUp"
      app>
      <v-list dense>
        <template v-for="item in items">
          <v-layout v-if="item.heading" :key="item.heading" align-center>
            <v-flex xs6>
              <v-subheader v-if="item.heading">{{ item.heading }}</v-subheader>
            </v-flex>
            <v-flex xs6 class="text-center">
              <a href="#!" class="body-2 black--text">EDIT</a>
            </v-flex>
          </v-layout>
          <v-list-group
            v-else-if="item.children"
            :key="item.text"
            v-model="item.model"
            :prepend-icon="item.model ? item.icon : item['icon-alt']"
            append-icon
          >
            <template v-slot:activator>
              <v-list-item>
                <v-list-item-content>
                  <v-list-item-title>{{ item.text }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item
              v-for="(child, i) in item.children"
              :key="i" 
              @click="clickMenu(child.id)">
              <v-list-item-action v-if="child.icon">
                <v-icon>{{ child.icon }}</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title>{{ child.text }}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-list-item v-else :key="item.text" @click="clickMenu(item.id)">
            <v-list-item-action>
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-item-action>
            <v-list-item-content>
              <v-list-item-title>{{ item.text }}</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </template>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar
      :clipped-left="$vuetify.breakpoint.lgAndUp"
      app
      color="blue darken-3"
      dark>
      <v-toolbar-title style="width: 300px" class="ml-0 pl-4">
        <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
        <span class="hidden-sm-and-down">住院病人入出转</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-tooltip right>
        <template v-slot:activator="{ on }">
          <v-btn icon to="/about" v-on="on">
            <v-icon>thumb_up_alt</v-icon>
          </v-btn>
        </template>
        <span>帮助手册</span>
      </v-tooltip>
      <v-btn icon to="/">
        <v-icon>notifications</v-icon>
      </v-btn>
      <v-btn icon large @click="selectSource">
        <v-avatar size="32px" item>
          <v-img :src="require('../assets/logo.svg')" alt="苜蓿草科技"></v-img>
        </v-avatar>
      </v-btn>
    </v-app-bar>
    <!-- <v-container fluid fill-height>
      <v-layout justify-start>
        <v-img :src="require('../assets/main_bg.jpg')" />
      </v-layout>
    </v-container>-->
    <v-tooltip right>
      <template v-slot:activator="{ on }">
        <v-btn
          bottom
          color="pink"
          dark
          fab
          fixed
          right 
          @click="clickMenu('logout')" 
          v-on="on">
          <v-icon>add</v-icon>
        </v-btn>
      </template>
      <span>退出登录</span>
    </v-tooltip>
  </div>
</template>

<script>
export default {
  props: {
    source: String
  },
  data: () => ({
    dialog: false,
    drawer: null,
    items: [
      { icon: "contacts", text: "入院登记", id: "adm_reg" },
      { icon: "history", text: "补预交金", id: "deposit" },
      { icon: "content_copy", text: "收费记账", id: "keep_accounts" },
      { icon: "keyboard", text: "出院结算", id: "discharge" },
      { icon: "keyboard", text: "交接班", id: "out_chk" },
      {
        icon: "keyboard_arrow_up",
        "icon-alt": "keyboard_arrow_down",
        text: "特殊操作",
        model: false,
        children: [
          { text: "出院结算召回", id: "discharge_undo" },
          { text: "医保患者修改卡密码", id: "micard_chgpass" },
          { text: "医保费用手动上传", id: "mi_fee_send" },
        ]
      },
      {
        icon: "keyboard_arrow_up",
        "icon-alt": "keyboard_arrow_down",
        text: "查询与统计",
        model: false,
        children: [
          { text: "在院患者一览表", id: "pat_sch" },
          { text: "患者费用明细", id: "pat_detail" },
          { text: "患者预交金明细", id: "pat_deposit" },
          { text: "住院患者日清单", id: "pat_detail_day" },
          { text: "操作日志", id: "detail_op" }
        ]
      },
      {
        icon: "settings",
        "icon-alt": "keyboard_arrow_down",
        text: "管理与维护",
        model: false,
        children: [
          { text: "收费词典查询", id: "mg_dict" },
          { text: "数据分析", id: "mg_analyse" },
          { text: "发票管理", id: "mg_invoice" }
        ]
      },
      { icon: "help", text: "退出登录", id: "logout" }
    ]
  }),
  methods: {
    clickMenu(tstr) {
      console.log("点击=" + tstr);
      if (tstr === "logout") {
        localStorage.removeItem("user");
        this.$router.push({ path: "/login" });
      }
      switch (tstr)
      {
        case "adm_reg":
          this.$router.push({ path: "/adm_reg" });
          break;

        case "deposit":
          this.$router.push({ path: "/deposit" });
          break;
        
        case "keep_accounts":
          this.$router.push({ path: "/keep_accounts" });
          break;

        case "discharge":
          this.$router.push({ path: "/discharge" });
          break;

        case "out_chk":
          this.$router.push({ path: "/out_chk" });
          break;

        case "discharge_undo":
          this.$router.push({ path: "/discharge_undo" });
          break;

        case "micard_chgpass":
          this.$router.push({ path: "/micard_chgpass" });
          break;
        
        case "mi_fee_send":
          this.$router.push({ path: "/mi_fee_send" });
          break;
          
        case "pat_sch":
          this.$router.push({ path: "/pat_sch" });
          break; 
          
        case "pat_detail":
          this.$router.push({ path: "/pat_detail" });
          break; 
        
        case "pat_deposit":
          this.$router.push({ path: "/pat_deposit" });
          break; 
        
        case "pat_detail_day":
          this.$router.push({ path: "/pat_detail_day" });
          break; 
        
        case "detail_op":
          this.$router.push({ path: "/detail_op" });
          break; 

        case "mg_dict":
          this.$router.push({ path: "/mg_dict" });
          break; 

        case "mg_analyse":
          this.$router.push({ path: "/mg_analyse" });
          break; 

        case "mg_invoice":
          this.$router.push({ path: "/mg_invoice" });
          break; 

        default:
          localStorage.removeItem("user");
          this.$router.push({ path: "/login" });
      }
    },

    selectSource() {
      window.location.href = "http://www.cloveropen.com";
    }
  }
};
</script>
