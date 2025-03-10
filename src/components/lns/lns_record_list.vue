<template>
  <div v-if="records.length > 0" class="lns-record-list">
    <div v-if="needsDecryption" class="decrypt q-pa-md row justify-between items-end">
      <WorktipsField :label="$t('fieldLabels.decryptRecord')" :disable="decrypting" :error="$v.name.$error">
        <q-input
          v-model.trim="name"
          :dark="theme == 'dark'"
          borderless
          dense
          :placeholder="$t('placeholders.lnsDecryptName')"
          :disable="decrypting"
          @blur="$v.name.$touch"
        />
      </WorktipsField>
      <div class="btn-wrapper q-ml-md row items-center">
        <q-btn color="primary" :label="$t('buttons.decrypt')" :loading="decrypting" @click="decrypt()" />
      </div>
    </div>
    <q-list link no-border :dark="theme == 'dark'" class="worktips-list">
      <q-item v-for="record in records" :key="record.name_hash" class="worktips-list-item">
        <q-item-section class="type" avatar>
          <q-icon :name="isLocked(record) ? 'lock' : 'lock_open'" size="24px" />
        </q-item-section>
        <q-item-section>
          <q-item-label :class="bindClass(record)">
            {{ isLocked(record) ? record.name_hash : record.name }}
          </q-item-label>
          <q-item-label v-if="!isLocked(record)">{{ record.value }}</q-item-label>
        </q-item-section>
        <q-item-section side class="height">
          <template v-if="isLocked(record)">
            {{ record.register_height | blockHeight }}
          </template>
          <template v-else>
            <q-item-section>
              <q-btn color="secondary" :label="$t('buttons.update')" @click="onUpdate(record)" />
            </q-item-section>
          </template>
        </q-item-section>
        <q-item-section v-if="!isLocked(record)" side>
          {{ record.register_height | blockHeight }}
        </q-item-section>
        <ContextMenu
          :menu-items="validMenuItems(record)"
          @ownerCopy="copy(record.owner, $t('notification.positive.ownerCopied'))"
          @nameCopy="copy(record.name, $t('notification.positive.nameCopied'))"
          @copyValue="copyValue(record)"
          @backupOwnerCopy="copy(record.backup_owner, $t('notification.positive.backupOwnerCopied'))"
        />
      </q-item>
    </q-list>
  </div>
</template>

<script>
const { clipboard } = require("electron");
import { mapState } from "vuex";
import { i18n } from "boot/i18n";
import WorktipsField from "components/worktips_field";
import { lns_name } from "src/validators/common";
import ContextMenu from "components/menus/contextmenu";

export default {
  name: "LNSRecordList",
  components: {
    WorktipsField,
    ContextMenu
  },
  filters: {
    blockHeight(value) {
      const heightString = i18n.t("strings.blockHeight");
      return `${heightString}: ${value}`;
    }
  },
  data() {
    return {
      name: "",
      decrypting: false
    };
  },
  computed: mapState({
    theme: state => state.gateway.app.config.appearance.theme,
    ourAddresses(state) {
      const { address_list } = state.gateway.wallet;
      const { used, unused, primary } = address_list;
      const all = [...used, ...unused, ...primary];
      return all.map(a => a.address).filter(a => !!a);
    },
    records(state) {
      const ourAddresses = this.ourAddresses;
      const records = state.gateway.wallet.lnsRecords;
      const ourRecords = records.filter(record => {
        return ourAddresses.includes(record.owner) || ourAddresses.includes(record.backup_owner);
      });

      // Sort the records by decrypted ones first, followed by non-decrypted
      return ourRecords.sort((a, b) => {
        if (a.name && !b.name) {
          return -1;
        } else if (b.name && !a.name) {
          return 1;
        } else if (a.name && b.name) {
          return a.name.localeCompare(b.name);
        }
        return b.register_height - a.register_height;
      });
    },
    needsDecryption() {
      return !!this.records.find(r => this.isLocked(r));
    }
  }),
  methods: {
    validMenuItems(record) {
      const lockedItems = [
        { action: "nameCopy", i18n: "menuItems.copyName" },
        { action: "copyValue", i18n: this.copyValueI18nLabel(record) }
      ];
      let menuItems = [{ action: "ownerCopy", i18n: "menuItems.copyOwner" }];
      const backupOwnerItem = [{ action: "backupOwnerCopy", i18n: "menuItems.copyBackupOwner" }];

      if (!this.isLocked(record)) {
        menuItems = [...lockedItems, ...menuItems];
      }
      if (record.backup_owner !== "") {
        menuItems = [...menuItems, ...backupOwnerItem];
      }
      return menuItems;
    },
    isLocked(record) {
      return !record.name || !record.value;
    },
    copyValueI18nLabel(record) {
      if (record.type === "session") {
        return "menuItems.copySessionId";
      }
      return "menuItems.copyAddress";
    },
    decrypt() {
      this.$v.name.$touch();

      if (!this.name || this.name.trim().length === 0) {
        this.$q.notify({
          type: "negative",
          timeout: 3000,
          message: this.$t("notification.errors.enterName")
        });
        return;
      }

      if (this.$v.name.$error) {
        this.$q.notify({
          type: "negative",
          timeout: 3000,
          message: this.$t("notification.errors.invalidNameFormat")
        });
        return;
      }

      const name = this.name.trim();

      this.$gateway.once("decrypt_record_result", data => {
        if (data.decrypted) {
          this.$q.notify({
            type: "positive",
            timeout: 2000,
            message: this.$t("notification.positive.decryptedLNSRecord", { name })
          });
          this.name = "";
        } else {
          this.$q.notify({
            type: "negative",
            timeout: 3000,
            message: this.$t("notification.errors.decryptLNSRecord", { name })
          });
        }
        this.decrypting = false;
      });
      this.$gateway.send("wallet", "decrypt_record", {
        name,
        type: "session"
      });
      this.decrypting = true;
    },
    bindClass(record) {
      return [this.isLocked(record) ? "locked" : "unlocked"];
    },
    onUpdate(record) {
      this.$emit("onUpdate", record);
    },
    copyValue(record) {
      let message = this.$t("notification.positive.addressCopied");
      if (record.type === "session") {
        message = this.$t("notification.positive.sessionIdCopied");
      }
      this.copy(record.value, message);
    },
    copy(value, message) {
      if (!value) return;
      clipboard.writeText(value.trim());
      this.$q.notify({
        type: "positive",
        timeout: 2000,
        message
      });
    }
  },
  validations: {
    name: {
      lns_name
    }
  }
};
</script>

<style lang="scss">
.lns-record-list {
  .height {
    font-size: 0.9em;
  }
  .q-item {
    cursor: default;
  }

  .worktips-field {
    flex: 1;
  }

  .decrypt {
    .btn-wrapper {
      height: 46px;
    }
  }
}
</style>
