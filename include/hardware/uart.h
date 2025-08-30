#ifndef AVR_SDK_HARDWARE_UART_H
#define AVR_SDK_HARDWARE_UART_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    UART_PARITY_NONE = 0,
    UART_PARITY_EVEN = 1,
    UART_PARITY_ODD = 2
} uart_parity_t;

typedef enum {
    UART_STOPBITS_1 = 0,
    UART_STOPBITS_2 = 1
} uart_stopbits_t;

typedef enum {
    UART_DATABITS_5 = 5,
    UART_DATABITS_6 = 6,
    UART_DATABITS_7 = 7,
    UART_DATABITS_8 = 8,
    UART_DATABITS_9 = 9
} uart_databits_t;

void uart_init(uint32_t baudrate);

void uart_deinit(void);

void uart_set_format(uart_databits_t data_bits, uart_stopbits_t stop_bits, uart_parity_t parity);

void uart_set_baudrate(uint32_t baudrate);

bool uart_is_readable(void);

bool uart_is_writable(void);

void uart_putc(char c);

char uart_getc(void);

void uart_puts(const char* s);

void uart_write(const uint8_t* src, size_t len);

void uart_read(uint8_t* dst, size_t len);

#ifdef __cplusplus
}
#endif

#endif  // AVR_SDK_HARDWARE_UART_H