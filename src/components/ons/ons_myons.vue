<template>
  <div class="my-ons">
    <div class="q-px-md q-pt-md">
      <div class="tab-desc">
        {{ $t("strings.onsDescription") }}
      </div>
      <ONSRecords @onUpdate="onUpdate" @onRenew="onRenew" />
    </div>
  </div>
</template>

<script>
import ONSRecords from "./ons_records";

export default {
  name: "MyONS",
  components: {
    ONSRecords
  },
  methods: {
    onUpdate(record) {
      this.$emit("onUpdate", record);
    },
    onRenew(record) {
      this.$emit("onRenew", record);
    }
  }
};
</script>

<style lang="scss">
.my-ons {
  .description {
    white-space: pre-line;
    color: #cecece;
    margin-bottom: 8px;
  }
}
</style>
