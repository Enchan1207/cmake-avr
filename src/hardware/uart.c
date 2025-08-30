#include "hardware/uart.h"
#include <avr/io.h>
#include <avr/interrupt.h>

#ifndef F_CPU
#error "F_CPU must be defined"
#endif

static volatile bool uart_initialized = false;

void uart_init(uint32_t baudrate) {
    if (uart_initialized) {
        return;
    }
    
    uint16_t ubrr = (F_CPU / (16UL * baudrate)) - 1;
    
    UBRR0H = (uint8_t)(ubrr >> 8);
    UBRR0L = (uint8_t)ubrr;
    
    UCSR0B = (1 << RXEN0) | (1 << TXEN0);
    
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
    
    uart_initialized = true;
}

void uart_deinit(void) {
    UCSR0B = 0;
    uart_initialized = false;
}

void uart_set_format(uart_databits_t data_bits, uart_stopbits_t stop_bits, uart_parity_t parity) {
    uint8_t ucsr0c = 0;
    
    switch(data_bits) {
        case UART_DATABITS_5:
            break;
        case UART_DATABITS_6:
            ucsr0c |= (1 << UCSZ00);
            break;
        case UART_DATABITS_7:
            ucsr0c |= (1 << UCSZ01);
            break;
        case UART_DATABITS_8:
            ucsr0c |= (1 << UCSZ01) | (1 << UCSZ00);
            break;
        case UART_DATABITS_9:
            ucsr0c |= (1 << UCSZ01) | (1 << UCSZ00);
            UCSR0B |= (1 << UCSZ02);
            break;
    }
    
    if (stop_bits == UART_STOPBITS_2) {
        ucsr0c |= (1 << USBS0);
    }
    
    switch(parity) {
        case UART_PARITY_NONE:
            break;
        case UART_PARITY_EVEN:
            ucsr0c |= (1 << UPM01);
            break;
        case UART_PARITY_ODD:
            ucsr0c |= (1 << UPM01) | (1 << UPM00);
            break;
    }
    
    UCSR0C = ucsr0c;
}

void uart_set_baudrate(uint32_t baudrate) {
    uint16_t ubrr = (F_CPU / (16UL * baudrate)) - 1;
    
    UBRR0H = (uint8_t)(ubrr >> 8);
    UBRR0L = (uint8_t)ubrr;
}

bool uart_is_readable(void) {
    return (UCSR0A & (1 << RXC0)) != 0;
}

bool uart_is_writable(void) {
    return (UCSR0A & (1 << UDRE0)) != 0;
}

void uart_putc(char c) {
    while (!uart_is_writable()) {
    }
    UDR0 = c;
}

char uart_getc(void) {
    while (!uart_is_readable()) {
    }
    return UDR0;
}

void uart_puts(const char* s) {
    while (*s) {
        uart_putc(*s++);
    }
}

void uart_write(const uint8_t* src, size_t len) {
    for (size_t i = 0; i < len; i++) {
        uart_putc(src[i]);
    }
}

void uart_read(uint8_t* dst, size_t len) {
    for (size_t i = 0; i < len; i++) {
        dst[i] = uart_getc();
    }
}