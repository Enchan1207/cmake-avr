#ifndef AVR_SDK_HARDWARE_GPIO_H
#define AVR_SDK_HARDWARE_GPIO_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    GPIO_FUNC_INPUT = 0,
    GPIO_FUNC_OUTPUT = 1,
    GPIO_FUNC_INPUT_PULLUP = 2
} gpio_function_t;

typedef enum {
    GPIO_IRQ_EDGE_RISE = 1,
    GPIO_IRQ_EDGE_FALL = 2,
    GPIO_IRQ_EDGE_BOTH = 3,
    GPIO_IRQ_LEVEL_LOW = 4,
    GPIO_IRQ_LEVEL_HIGH = 8
} gpio_irq_level_t;

typedef void (*gpio_irq_callback_t)(uint8_t gpio, uint32_t events);

void gpio_init(uint8_t gpio);

void gpio_set_function(uint8_t gpio, gpio_function_t func);

gpio_function_t gpio_get_function(uint8_t gpio);

void gpio_set_dir(uint8_t gpio, bool out);

bool gpio_get_dir(uint8_t gpio);

void gpio_put(uint8_t gpio, bool value);

bool gpio_get(uint8_t gpio);

void gpio_pull_up(uint8_t gpio);

void gpio_pull_down(uint8_t gpio);

void gpio_disable_pulls(uint8_t gpio);

void gpio_set_irq_enabled(uint8_t gpio, uint32_t events, bool enabled);

void gpio_set_irq_callback(gpio_irq_callback_t callback);

void gpio_acknowledge_irq(uint8_t gpio, uint32_t events);

#ifdef __cplusplus
}
#endif

#endif  // AVR_SDK_HARDWARE_GPIO_H