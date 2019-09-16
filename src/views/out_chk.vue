<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <out_chkc />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import out_chkc from "../components/out_chkc";
export default {
  components: {
    Basepage,
    out_chkc
  }
};
</script>
