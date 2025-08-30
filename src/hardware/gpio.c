#include "hardware/gpio.h"
#include <avr/io.h>
#include <avr/interrupt.h>

static gpio_irq_callback_t gpio_callback = NULL;

static volatile uint8_t* gpio_get_port_reg(uint8_t gpio) {
    uint8_t port = gpio / 8;
    switch (port) {
        case 0: return &PORTB;
        case 1: return &PORTC;
        case 2: return &PORTD;
        default: return NULL;
    }
}

static volatile uint8_t* gpio_get_ddr_reg(uint8_t gpio) {
    uint8_t port = gpio / 8;
    switch (port) {
        case 0: return &DDRB;
        case 1: return &DDRC;
        case 2: return &DDRD;
        default: return NULL;
    }
}

static volatile uint8_t* gpio_get_pin_reg(uint8_t gpio) {
    uint8_t port = gpio / 8;
    switch (port) {
        case 0: return &PINB;
        case 1: return &PINC;
        case 2: return &PIND;
        default: return NULL;
    }
}

void gpio_init(uint8_t gpio) {
    gpio_set_function(gpio, GPIO_FUNC_INPUT);
}

void gpio_set_function(uint8_t gpio, gpio_function_t func) {
    volatile uint8_t* ddr = gpio_get_ddr_reg(gpio);
    volatile uint8_t* port = gpio_get_port_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!ddr || !port) return;
    
    switch (func) {
        case GPIO_FUNC_INPUT:
            *ddr &= ~(1 << pin);
            *port &= ~(1 << pin);
            break;
        case GPIO_FUNC_OUTPUT:
            *ddr |= (1 << pin);
            break;
        case GPIO_FUNC_INPUT_PULLUP:
            *ddr &= ~(1 << pin);
            *port |= (1 << pin);
            break;
    }
}

gpio_function_t gpio_get_function(uint8_t gpio) {
    volatile uint8_t* ddr = gpio_get_ddr_reg(gpio);
    volatile uint8_t* port = gpio_get_port_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!ddr || !port) return GPIO_FUNC_INPUT;
    
    if (*ddr & (1 << pin)) {
        return GPIO_FUNC_OUTPUT;
    } else if (*port & (1 << pin)) {
        return GPIO_FUNC_INPUT_PULLUP;
    } else {
        return GPIO_FUNC_INPUT;
    }
}

void gpio_set_dir(uint8_t gpio, bool out) {
    volatile uint8_t* ddr = gpio_get_ddr_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!ddr) return;
    
    if (out) {
        *ddr |= (1 << pin);
    } else {
        *ddr &= ~(1 << pin);
    }
}

bool gpio_get_dir(uint8_t gpio) {
    volatile uint8_t* ddr = gpio_get_ddr_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!ddr) return false;
    
    return (*ddr & (1 << pin)) != 0;
}

void gpio_put(uint8_t gpio, bool value) {
    volatile uint8_t* port = gpio_get_port_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!port) return;
    
    if (value) {
        *port |= (1 << pin);
    } else {
        *port &= ~(1 << pin);
    }
}

bool gpio_get(uint8_t gpio) {
    volatile uint8_t* pin_reg = gpio_get_pin_reg(gpio);
    uint8_t pin = gpio % 8;
    
    if (!pin_reg) return false;
    
    return (*pin_reg & (1 << pin)) != 0;
}

void gpio_pull_up(uint8_t gpio) {
    gpio_set_function(gpio, GPIO_FUNC_INPUT_PULLUP);
}

void gpio_pull_down(uint8_t gpio) {
    gpio_set_function(gpio, GPIO_FUNC_INPUT);
}

void gpio_disable_pulls(uint8_t gpio) {
    gpio_set_function(gpio, GPIO_FUNC_INPUT);
}

void gpio_set_irq_enabled(uint8_t gpio, uint32_t events, bool enabled) {
    (void)gpio;
    (void)events;
    (void)enabled;
}

void gpio_set_irq_callback(gpio_irq_callback_t callback) {
    gpio_callback = callback;
}

void gpio_acknowledge_irq(uint8_t gpio, uint32_t events) {
    (void)gpio;
    (void)events;
}