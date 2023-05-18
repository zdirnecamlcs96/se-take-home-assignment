import { describe, it, expect } from 'vitest'

import { mount } from '@vue/test-utils'
import PrimaryButton from '../PrimaryButton.vue'

describe('PrimaryButton', () => {
    it('renders properly', () => {
        const wrapper = mount(PrimaryButton, { props: { text: '- Bot' } })
        expect(wrapper.text()).toContain('- Bot')
    })

    it('emit click event', async () => {
        const wrapper = mount(PrimaryButton, { props: { text: '- Bot' } })
        await wrapper.trigger('click')
        expect(wrapper.emitted().click).toBeTruthy()
    })
})

