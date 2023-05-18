import { describe, it, expect } from 'vitest'

import { mount } from '@vue/test-utils'
import OrderCard from '../OrderCard.vue'

describe('OrderCard', () => {
    it('renders properly', () => {
        const vip = Math.random() < 0.5
        const wrapper = mount(OrderCard, { props: { order: {
            uuid: 1,
            vip: vip,
        } } })
        expect(wrapper.text()).toContain('Order 1 ' + (vip ? 'VIP' : 'Normal'))
    })
})

