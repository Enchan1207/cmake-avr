#
# CMake AVR toolchain
#
# 2023-2025 @Enchan1207
#

# cross-compiling
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

# commands
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-g++)
set(CMAKE_LINKER avr-ld)
set(CMAKE_OBJCOPY avr-objcopy)
set(CMAKE_OBJDUMP avr-objdump)
set(CMAKE_NM avr-nm)
set(CMAKE_AR avr-ar)
set(CMAKE_RANLIB avr-ranlib)
set(CMAKE_STRIP avr-strip)

# toolchain options
set(AVR_MCU "atmega328p" CACHE STRING "target MCU identifier")
set(AVR_FCPU "16000000" CACHE STRING "frequency of target")

# flags
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(OPTIMIZATION_FLAGS "-Os")
else()
    set(OPTIMIZATION_FLAGS "-Os -g")
endif()
set(CMAKE_C_FLAGS_INIT   "-mmcu=${AVR_MCU} ${OPTIMIZATION_FLAGS} -DF_CPU=${AVR_FCPU}")
set(CMAKE_CXX_FLAGS_INIT "-mmcu=${AVR_MCU} ${OPTIMIZATION_FLAGS} -DF_CPU=${AVR_FCPU}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-mmcu=${AVR_MCU}")

# macro for target configuration
macro(avr_add_extra_outputs target_name)
    get_target_property(target_type ${target_name} TYPE)
    if(target_type STREQUAL "EXECUTABLE")
        set(${target_name}_IS_EXECUTABLE TRUE)
    else()
        set(${target_name}_IS_EXECUTABLE FALSE)
    endif()

    if(${target_name}_IS_EXECUTABLE)
        add_custom_command(TARGET ${target_name} POST_BUILD
            COMMAND ${CMAKE_OBJDUMP} -P mem-usage $<TARGET_FILE:${target_name}>
            COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${target_name}> $<TARGET_FILE_DIR:${target_name}>/${target_name}.hex
        )
    endif()
endmacro()
