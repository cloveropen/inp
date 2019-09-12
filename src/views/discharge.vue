<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />    
    <v-container fluid fill-height>
      <v-layout justify-start>
        <test />
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
import test from "../components/HelloWorld";
export default {
  components: {
    Basepage,
    test
  }
};
</script>
