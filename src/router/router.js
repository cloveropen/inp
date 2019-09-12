import Vue from "vue";
import Router from "vue-router";
import Home from "../views/Home.vue";

Vue.use(Router);

export const router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/about",
      name: "about",
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () =>
        import(/* webpackChunkName: "about" */ "../views/About.vue")
    },   
    {
      path: "/adm_reg",
      name: "adm_reg",
      component: () =>
        import(/* webpackChunkName: "adm_reg" */ "../views/adm_reg.vue")
    }, 
    {
      path: "/deposit",
      name: "deposit",
      component: () =>
        import(/* webpackChunkName: "deposit" */ "../views/deposit.vue")
    }, 
    {
      path: "/keep_accounts",
      name: "keep_accounts",
      component: () =>
        import(/* webpackChunkName: "keep_accounts" */ "../views/keep_accounts.vue")
    },
    {
      path: "/discharge",
      name: "discharge",
      component: () =>
        import(/* webpackChunkName: "discharge" */ "../views/discharge.vue")
    },
    {
      path: "/out_chk",
      name: "out_chk",
      component: () =>
        import(/* webpackChunkName: "out_chk" */ "../views/out_chk.vue")
    },
    {
      path: "/discharge_undo",
      name: "discharge_undo",
      component: () =>
        import(/* webpackChunkName: "discharge_undo" */ "../views/discharge_undo.vue")
    },
    {
      path: "/micard_chgpass",
      name: "micard_chgpass",
      component: () =>
        import(/* webpackChunkName: "micard_chgpass" */ "../views/micard_chgpass.vue")
    },
    {
      path: "/mi_fee_send",
      name: "mi_fee_send",
      component: () =>
        import(/* webpackChunkName: "mi_fee_send" */ "../views/mi_fee_send.vue")
    },
    {
      path: "/pat_sch",
      name: "pat_sch",
      component: () =>
        import(/* webpackChunkName: "pat_sch" */ "../views/pat_sch.vue")
    },
    {
      path: "/pat_detail",
      name: "pat_detail",
      component: () =>
        import(/* webpackChunkName: "pat_detail" */ "../views/pat_detail.vue")
    },
    {
      path: "/pat_deposit",
      name: "pat_deposit",
      component: () =>
        import(/* webpackChunkName: "pat_deposit" */ "../views/pat_deposit.vue")
    },
    {
      path: "/pat_detail_day",
      name: "pat_detail_day",
      component: () =>
        import(/* webpackChunkName: "pat_detail_day" */ "../views/pat_detail_day.vue")
    },
    {
      path: "/pat_detail_day",
      name: "pat_detail_day",
      component: () =>
        import(/* webpackChunkName: "pat_detail_day" */ "../views/pat_detail_day.vue")
    },
    {
      path: "/detail_op",
      name: "detail_op",
      component: () =>
        import(/* webpackChunkName: "detail_op" */ "../views/detail_op.vue")
    },
    {
      path: "/mg_dict",
      name: "mg_dict",
      component: () =>
        import(/* webpackChunkName: "mg_dict" */ "../views/mg_dict.vue")
    },
    {
      path: "/mg_analyse",
      name: "mg_analyse",
      component: () =>
        import(/* webpackChunkName: "mg_analyse" */ "../views/mg_analyse.vue")
    },
    {
      path: "/mg_invoice",
      name: "mg_invoice",
      component: () =>
        import(/* webpackChunkName: "mg_invoice" */ "../views/mg_invoice.vue")
    },
    {
      path: "/login",
      name: "login",
      component: () =>
        import(/* webpackChunkName: "login" */ "../views/Login.vue")
    }
  ]
});

router.beforeEach((to, from, next) => {
  // redirect to login page if not logged in and trying to access a restricted page
  const publicPages = ["/login", "/register"];
  const authRequired = !publicPages.includes(to.path);
  const loggedIn = localStorage.getItem("user");
  // console.log("authRequired=" + authRequired + " loggedIn=" + loggedIn);
  if (authRequired && !loggedIn) {
    return next("/login");
  }

  next();
});
