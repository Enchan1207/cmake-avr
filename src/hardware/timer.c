#include "hardware/timer.h"
#include <avr/io.h>
#include <avr/interrupt.h>

#ifndef F_CPU
#error "F_CPU must be defined"
#endif

static timer_callback_t timer0_callbacks[3] = {NULL, NULL, NULL};
static timer_callback_t timer1_callbacks[3] = {NULL, NULL, NULL};
static timer_callback_t timer2_callbacks[3] = {NULL, NULL, NULL};

void timer_init(uint8_t timer_num, timer_mode_t mode) {
    switch (timer_num) {
        case 0:
            TCCR0A = 0;
            TCCR0B = 0;
            TCNT0 = 0;
            OCR0A = 0;
            OCR0B = 0;
            
            switch (mode) {
                case TIMER_MODE_NORMAL:
                    break;
                case TIMER_MODE_CTC:
                    TCCR0A |= (1 << WGM01);
                    break;
                case TIMER_MODE_FAST_PWM:
                    TCCR0A |= (1 << WGM00) | (1 << WGM01);
                    break;
                case TIMER_MODE_PHASE_CORRECT_PWM:
                    TCCR0A |= (1 << WGM00);
                    break;
            }
            break;
            
        case 1:
            TCCR1A = 0;
            TCCR1B = 0;
            TCNT1 = 0;
            OCR1A = 0;
            OCR1B = 0;
            
            switch (mode) {
                case TIMER_MODE_NORMAL:
                    break;
                case TIMER_MODE_CTC:
                    TCCR1B |= (1 << WGM12);
                    break;
                case TIMER_MODE_FAST_PWM:
                    TCCR1A |= (1 << WGM10);
                    TCCR1B |= (1 << WGM12);
                    break;
                case TIMER_MODE_PHASE_CORRECT_PWM:
                    TCCR1A |= (1 << WGM10);
                    break;
            }
            break;
            
        case 2:
            TCCR2A = 0;
            TCCR2B = 0;
            TCNT2 = 0;
            OCR2A = 0;
            OCR2B = 0;
            
            switch (mode) {
                case TIMER_MODE_NORMAL:
                    break;
                case TIMER_MODE_CTC:
                    TCCR2A |= (1 << WGM21);
                    break;
                case TIMER_MODE_FAST_PWM:
                    TCCR2A |= (1 << WGM20) | (1 << WGM21);
                    break;
                case TIMER_MODE_PHASE_CORRECT_PWM:
                    TCCR2A |= (1 << WGM20);
                    break;
            }
            break;
    }
}

void timer_deinit(uint8_t timer_num) {
    switch (timer_num) {
        case 0:
            TCCR0A = 0;
            TCCR0B = 0;
            TIMSK0 = 0;
            break;
        case 1:
            TCCR1A = 0;
            TCCR1B = 0;
            TIMSK1 = 0;
            break;
        case 2:
            TCCR2A = 0;
            TCCR2B = 0;
            TIMSK2 = 0;
            break;
    }
}

void timer_set_prescaler(uint8_t timer_num, timer_prescaler_t prescaler) {
    uint8_t cs_bits = 0;
    
    switch (prescaler) {
        case TIMER_PRESCALER_1:
            cs_bits = 1;
            break;
        case TIMER_PRESCALER_8:
            cs_bits = 2;
            break;
        case TIMER_PRESCALER_64:
            cs_bits = 3;
            break;
        case TIMER_PRESCALER_256:
            cs_bits = 4;
            break;
        case TIMER_PRESCALER_1024:
            cs_bits = 5;
            break;
    }
    
    switch (timer_num) {
        case 0:
            TCCR0B = (TCCR0B & 0xF8) | cs_bits;
            break;
        case 1:
            TCCR1B = (TCCR1B & 0xF8) | cs_bits;
            break;
        case 2:
            TCCR2B = (TCCR2B & 0xF8) | cs_bits;
            break;
    }
}

void timer_set_compare_value(uint8_t timer_num, uint8_t compare_reg, uint16_t value) {
    switch (timer_num) {
        case 0:
            if (compare_reg == 0) OCR0A = (uint8_t)value;
            else if (compare_reg == 1) OCR0B = (uint8_t)value;
            break;
        case 1:
            if (compare_reg == 0) OCR1A = value;
            else if (compare_reg == 1) OCR1B = value;
            break;
        case 2:
            if (compare_reg == 0) OCR2A = (uint8_t)value;
            else if (compare_reg == 1) OCR2B = (uint8_t)value;
            break;
    }
}

uint16_t timer_get_counter(uint8_t timer_num) {
    switch (timer_num) {
        case 0:
            return TCNT0;
        case 1:
            return TCNT1;
        case 2:
            return TCNT2;
        default:
            return 0;
    }
}

void timer_set_counter(uint8_t timer_num, uint16_t value) {
    switch (timer_num) {
        case 0:
            TCNT0 = (uint8_t)value;
            break;
        case 1:
            TCNT1 = value;
            break;
        case 2:
            TCNT2 = (uint8_t)value;
            break;
    }
}

void timer_enable_interrupt(uint8_t timer_num, uint8_t interrupt_mask) {
    switch (timer_num) {
        case 0:
            TIMSK0 |= interrupt_mask;
            break;
        case 1:
            TIMSK1 |= interrupt_mask;
            break;
        case 2:
            TIMSK2 |= interrupt_mask;
            break;
    }
}

void timer_disable_interrupt(uint8_t timer_num, uint8_t interrupt_mask) {
    switch (timer_num) {
        case 0:
            TIMSK0 &= ~interrupt_mask;
            break;
        case 1:
            TIMSK1 &= ~interrupt_mask;
            break;
        case 2:
            TIMSK2 &= ~interrupt_mask;
            break;
    }
}

void timer_set_callback(uint8_t timer_num, uint8_t interrupt_type, timer_callback_t callback) {
    switch (timer_num) {
        case 0:
            if (interrupt_type < 3) timer0_callbacks[interrupt_type] = callback;
            break;
        case 1:
            if (interrupt_type < 3) timer1_callbacks[interrupt_type] = callback;
            break;
        case 2:
            if (interrupt_type < 3) timer2_callbacks[interrupt_type] = callback;
            break;
    }
}

void timer_start(uint8_t timer_num) {
    timer_set_prescaler(timer_num, TIMER_PRESCALER_64);
}

void timer_stop(uint8_t timer_num) {
    switch (timer_num) {
        case 0:
            TCCR0B &= 0xF8;
            break;
        case 1:
            TCCR1B &= 0xF8;
            break;
        case 2:
            TCCR2B &= 0xF8;
            break;
    }
}

uint32_t timer_get_frequency_hz(uint8_t timer_num) {
    (void)timer_num;
    return F_CPU / 64;
}

ISR(TIMER0_OVF_vect) {
    if (timer0_callbacks[0]) {
        timer0_callbacks[0]();
    }
}

ISR(TIMER0_COMPA_vect) {
    if (timer0_callbacks[1]) {
        timer0_callbacks[1]();
    }
}

ISR(TIMER0_COMPB_vect) {
    if (timer0_callbacks[2]) {
        timer0_callbacks[2]();
    }
}