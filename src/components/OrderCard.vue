<script setup>
    import { defineProps, computed } from 'vue';

    const props = defineProps({
        completed: {
            type: Boolean,
            required: false
        },
        order: {
            type: Object,
            required: true
        }
    });

    const vipMsg = computed(() => {
        return props.order.vip ? 'VIP' : 'Normal'
    })

    const completedText = computed(() => {
        return props.order.bot ? `${props.completed ? 'Processed' : 'Processing by'} by Cooking Bot #${props.order.bot}` : 'Waiting for bot'
    });

</script>
<template>
    <div class="mb-3">
        <span class="mr-2">Order <b>#{{ order.uuid }}</b></span>
        <span class="rounded px-2 text-sm" :class="order.vip ? `bg-orange-600 text-amber-200` : `bg-gray-100`">{{ vipMsg }}</span> => <small>{{ completedText }}</small>
    </div>
</template>