cmake_minimum_required(VERSION 3.12)

# Hardware UART library
add_library(hardware_uart STATIC
    ${AVR_SDK_PATH}/src/hardware/uart.c
)

target_include_directories(hardware_uart
    PUBLIC ${AVR_SDK_PATH}/include
)

# Hardware GPIO library
add_library(hardware_gpio STATIC
    ${AVR_SDK_PATH}/src/hardware/gpio.c
)

target_include_directories(hardware_gpio
    PUBLIC ${AVR_SDK_PATH}/include
)

# Hardware Timer library
add_library(hardware_timer STATIC
    ${AVR_SDK_PATH}/src/hardware/timer.c
)

target_include_directories(hardware_timer
    PUBLIC ${AVR_SDK_PATH}/include
)
