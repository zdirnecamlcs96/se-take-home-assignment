<script setup>

defineProps({
    triggerClick: {
        type: Function,
        required: true
    },
    text: {
        type: String,
        required: true
    },
    disabled: {
        type: Boolean,
        default: false
    }
});

</script>

<template>
    <button @click="$emit('triggerClick')" class="bg-blue-800 text-white mr-3 px-3 font-bold rounded disabled:opacity-80" :disabled="disabled">{{ text }}</button>
</template>