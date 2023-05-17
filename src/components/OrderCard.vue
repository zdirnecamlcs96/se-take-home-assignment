<script setup>
    import { defineProps, computed } from 'vue';

    const props = defineProps({
        order: {
            type: Object,
            required: true
        }
    });

    const vipMsg = computed(() => {
        return props.order.vip ? 'VIP' : 'Normal'
    })

</script>
<template>
    Order {{ order.uuid }}
    <span class="rounded px-3" :class="order.vip ? `bg-orange-600 text-amber-200` : `bg-gray-100`">{{ vipMsg }}</span>
</template>