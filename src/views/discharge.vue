<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <dischargec />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import dischargec from "../components/dischargec";
export default {
  components: {
    Basepage,
    dischargec
  }
};
</script>
