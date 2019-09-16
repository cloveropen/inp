<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <depositc />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import depositc from "../components/depositc";
export default {
  components: {
    Basepage,
    depositc
  }
};
</script>
