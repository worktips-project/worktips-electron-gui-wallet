<template>
  <div class="ons-purchase">
    <div class="q-mb-lg q-px-md q-pt-md">
      <div class="tab-desc">
        {{ $t("strings.onsPurchaseDescription") }}
      </div>
      <div class="prices">
        {{ $t("strings.ons.prices") }}
        <table>
          <tr>
            <td>{{ $t("strings.ons.sessionID") }}:</td>
            <td>15 OXEN</td>
          </tr>
          <tr>
            <td>{{ $t("strings.ons.wallet") }}:</td>
            <td>15 OXEN</td>
          </tr>
          <tr>
            <td>{{ $t("strings.ons.lokinetName1Year") }}:</td>
            <td>15 OXEN</td>
          </tr>
          <tr>
            <td>{{ $t("strings.ons.lokinetNameXYears", { years: 2 }) }}:</td>
            <td>30 OXEN</td>
          </tr>
          <tr>
            <td>{{ $t("strings.ons.lokinetNameXYears", { years: 5 }) }}:</td>
            <td>60 OXEN</td>
          </tr>
          <tr>
            <td>{{ $t("strings.ons.lokinetNameXYears", { years: 10 }) }}:</td>
            <td>90 OXEN</td>
          </tr>
        </table>
      </div>
      <ONSInput ref="input" />
    </div>
  </div>
</template>

<script>
import ONSInput from "./ons_input";
export default {
  name: "ONSPurchase",
  components: {
    ONSInput
  },
  methods: {
    startUpdating(record) {
      this.$refs.input.startUpdating(record);
    },
    startRenewing(record) {
      this.$refs.input.startRenewing(record);
    }
  }
};
</script>
<style lang="scss">
.ons-purchase {
  .description {
    white-space: pre-line;
    // oxen-navy
    color: #1f1c47;
  }

  .prices {
    // oxen-navy
    margin-top: 20px;
    color: #1f1c47;
  }
}
</style>
