<script setup>
  import { ref, reactive } from 'vue';
  import OrderCard from '@/components/OrderCard.vue';
  import PrimaryButton from '@/components/PrimaryButton.vue';

  const bots = reactive([]);
  const orders = reactive([]);
  const completedOrders = reactive([]);
  const orderUUID = ref(1);
  const botUUID = ref(1);

  const addOrder = async (vip = false) => {
    const order = reactive({
      uuid: orderUUID.value,
      vip: vip
    });

    if (vip) {
        orders.unshift(order);
    } else {
      orders.push(order);
    }

    orderUUID.value++;
    assignOrderToBot();
  }

  const addBot = async () => {
    const bot = reactive({
      uuid: botUUID.value,
      name: `Bot ${bots.length + 1}`,
      order: undefined,
      timer: 0
    });

    bots.push(bot);
    assignOrderToBot();
    botUUID.value++;
  }

  const removeBot = async () => {
    const bot = bots[0];

    if (bot) {
      const order = await orders.find(order => order.uuid === bot.order);

      if (order) {
        order.bot = undefined;
        clearTimeout(bot.timerId);
      }
    }

    bots.pop();

  }

  const assignOrderToBot = async () => {

    const order = orders.filter(o => !o.bot).shift()

    // Check idle bot
    const bot = bots.find(bot => bot.order === undefined);

    // Check order is pending
    if (order && bot) {
      bot.order = order.uuid;
      order.bot = bot.uuid;
      startProcessingTimer(bot);
    }
  }

  const startProcessingTimer = async (bot) => {
    bot.timer = 10; // Initial timer value
    bot.timerId = undefined;

    const timerId = setInterval(() => {
      bot.timer -= 1; // Decrease the timer by 1 second
      if (bot.timer <= 0) {
        clearInterval(timerId);

        const order = orders.find(order => order.uuid === bot.order);

        if (order) {
          // move order to completed list
          completedOrders.push(order);

          // remove order from pending list based on uuid
          orders.splice(orders.findIndex(order => order.uuid === bot.order), 1);
        }

        bot.order = undefined;
        assignOrderToBot();
      }
    }, 1000); // Update the timer every second

    bot.timerId = timerId;
  };

</script>

<template>
  <div class="about">
    <div class="bg-slate-200 rounded text-gray-800 p-3 mb-3">
      <h3 class="text-2xl font-bold mb-1">Bots</h3>
      <PrimaryButton @triggerClick="addBot" :text="`+ Bot`"/>
      <PrimaryButton @triggerClick="removeBot" :text="`- Bot`"/>
      <ul class="mt-3">
        <li v-for="bot in bots" :key="bot.uuid">
          {{ bot.name }}
          <span class="bg-gray-100 rounded px-3">{{ bot.order ? `Processing Order ${bot.order} (${ bot.timer }s)` : 'Idle' }}</span>
        </li>
      </ul>
    </div>

    <div class="bg-slate-200 rounded text-gray-800 p-3 mb-3">
      <h3 class="text-2xl font-bold mb-1">Pending Orders</h3>
      <PrimaryButton @triggerClick="addOrder(false)" :text="`+ Order`"/>
      <PrimaryButton @triggerClick="addOrder(true)" :text="`+ VIP Order`"/>
      <ul class="mt-3">
        <li v-for="order in orders.filter(o => o.status === PENDING_STATUS)" :key="order.uuid">
          <OrderCard :order="order" />
        </li>
      </ul>
    </div>

    <div class="bg-slate-200 rounded text-gray-800 p-3 mb-3">
      <h3 class="text-2xl font-bold mb-1">Completed Orders</h3>
      <ul class="mt-3">
        <li v-for="order in completedOrders" :key="order.uuid">
          <OrderCard :order="order" />
        </li>
      </ul>
    </div>
  </div>
</template>
