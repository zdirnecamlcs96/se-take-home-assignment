<script setup>
  import { ref, reactive, watch, isProxy, toRaw } from 'vue';

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

    const bot = bots.shift();

    if (bot) {
      const order = orders.find(order => order.uuid === bot.order);
      order.bot = undefined;
      clearTimeout(bot.timerId);
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

  const startProcessingTimer = (bot) => {
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
      }, 10000); // Update the timer every second

      bot.timerId = timerId;
    };

</script>

<template>
  <div class="about">
    <div class="mb-3 underline">
      <p>Bot List:</p>
      <button @click="addBot">+ Bot</button>
      <button @click="removeBot">- Bot</button>
      <ul>
        <li v-for="bot in bots" :key="bot.uuid">
          {{ bot.name }} - {{ bot.order ? `Processing Order ${bot.order}` : 'Idle' }}
        </li>
      </ul>
    </div>

    <div>
      <p>Pending Order List:</p>
      <button @click="addOrder(false)">New Normal Order</button>
      <button @click="addOrder(true)">New VIP Order</button>
      <ul>
        <li v-for="order in orders.filter(o => o.status === PENDING_STATUS)" :key="order.uuid">
          Order {{ order.uuid }} - {{ order.status }}
          <br/>
          {{ order.vip ? 'VIP' : 'NORMAL' }}
        </li>
      </ul>
    </div>

    <div>
      <p>Completed Order List:</p>
      <ul>
        <li v-for="order in completedOrders" :key="order.uuid">
          Order {{ order.uuid }} - {{ order.status }}
          <br/>
          {{ order.vip ? 'VIP' : 'NORMAL' }}
        </li>
      </ul>
    </div>
  </div>
</template>
