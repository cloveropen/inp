<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <keep_accountsc />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import keep_accountsc from "../components/keep_accountsc";
export default {
  components: {
    Basepage,
    keep_accountsc
  }
};
</script>
