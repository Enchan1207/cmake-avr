#ifndef AVR_SDK_HARDWARE_TIMER_H
#define AVR_SDK_HARDWARE_TIMER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TIMER_MODE_NORMAL = 0,
    TIMER_MODE_CTC = 1,
    TIMER_MODE_FAST_PWM = 2,
    TIMER_MODE_PHASE_CORRECT_PWM = 3
} timer_mode_t;

typedef enum {
    TIMER_PRESCALER_1 = 1,
    TIMER_PRESCALER_8 = 8,
    TIMER_PRESCALER_64 = 64,
    TIMER_PRESCALER_256 = 256,
    TIMER_PRESCALER_1024 = 1024
} timer_prescaler_t;

typedef void (*timer_callback_t)(void);

void timer_init(uint8_t timer_num, timer_mode_t mode);

void timer_deinit(uint8_t timer_num);

void timer_set_prescaler(uint8_t timer_num, timer_prescaler_t prescaler);

void timer_set_compare_value(uint8_t timer_num, uint8_t compare_reg, uint16_t value);

uint16_t timer_get_counter(uint8_t timer_num);

void timer_set_counter(uint8_t timer_num, uint16_t value);

void timer_enable_interrupt(uint8_t timer_num, uint8_t interrupt_mask);

void timer_disable_interrupt(uint8_t timer_num, uint8_t interrupt_mask);

void timer_set_callback(uint8_t timer_num, uint8_t interrupt_type, timer_callback_t callback);

void timer_start(uint8_t timer_num);

void timer_stop(uint8_t timer_num);

uint32_t timer_get_frequency_hz(uint8_t timer_num);

#ifdef __cplusplus
}
#endif

#endif  // AVR_SDK_HARDWARE_TIMER_H