#
# CMake AVR toolchain with arduino-cli
#
# 2023 @Enchan1207
#
cmake_minimum_required(VERSION 3.0)
set(BUILD_FOR_AVR TRUE)

#
# arduino-cliを探す
#
set(ARDUINOCLI_ROOT "" CACHE PATH "Path to root of arduino-cli")
if(NOT ARDUINOCLI_ROOT)
    if(DEFINED ENV{ARDUINOCLI_ROOT})
        set(ARDUINOCLI_ROOT "$ENV{ARDUINOCLI_ROOT}")
    else()
        if(APPLE)
            set(ARDUINOCLI_ROOT "~/Library/Arduino15")
        elseif(UNIX)
            set(ARDUINOCLI_ROOT "~/.arduino15")
        else()
            set(ARDUINOCLI_ROOT "~/AppData/Local/Arduino15")
        endif()
    endif()
    get_filename_component(ARDUINOCLI_ROOT "${ARDUINOCLI_ROOT}" ABSOLUTE)
    if(NOT EXISTS ${ARDUINOCLI_ROOT})
        message(FATAL_ERROR
            "The directory `tools` of arduino-cli not found. (expected: ${ARDUINOCLI_ROOT})\n"
            "Solution:\n"
            "1. Check if arduino-cli and avr core were installed\n"
            "2. Set correct path to environment variable ARDUINOCLI_ROOT \n
                if you installed arduino-cli to custom directory\n"
        )
    endif()
endif()

#
# avr-gcc, avrdudeのバリアントを取得し、最新版のパスを変数に設定
#
set(AVRGCC_ROOT "" CACHE PATH "Path to root of avr-gcc")
if(NOT AVRGCC_ROOT)
    file(GLOB AVRGCC_VARIANTS ${ARDUINOCLI_ROOT}/packages/arduino/tools/avr-gcc/*)
    list(SORT AVRGCC_VARIANTS ORDER DESCENDING)
    list(GET AVRGCC_VARIANTS 0 AVRGCC_ROOT)
    if(NOT AVRGCC_ROOT)
        message(FATAL_ERROR "The command avr-gcc not found.")
    endif()
endif()
set(AVRGCC_BIN ${AVRGCC_ROOT}/bin)

set(AVRDUDE_ROOT "" CACHE PATH "Path to root of avrdude")
if(NOT AVRDUDE_ROOT)
    file(GLOB AVRDUDE_VARIANTS ${ARDUINOCLI_ROOT}/packages/arduino/tools/avrdude/*)
    list(SORT AVRDUDE_VARIANTS ORDER DESCENDING)
    list(GET AVRDUDE_VARIANTS 0 AVRDUDE_ROOT)
    if(NOT AVRDUDE_ROOT)
        message(FATAL_ERROR "The command avrdude not found.")
    endif()
endif()

# ついでにavrdudeの初期設定
set(AVRDUDE_BIN ${AVRDUDE_ROOT}/bin)
set(AVRDUDE_CONF ${AVRDUDE_ROOT}/etc/avrdude.conf)
if(NOT EXISTS ${AVRDUDE_CONF})
    message(FATAL_ERROR "The configuration file for avrdude (avrdude.conf) not found.")
endif()

#
# CMakeが使用するコマンドの設定
#

# AVR向けのクロスコンパイルであることを明示
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_C_COMPILER_TARGET avr)
set(CMAKE_CROSS_COMPILING 1)

# 各コマンドのパスを設定
set(CMAKE_C_COMPILER "${AVRGCC_BIN}/avr-gcc" CACHE PATH "c compiler" FORCE)
set(CMAKE_CXX_COMPILER "${AVRGCC_BIN}/avr-g++" CACHE PATH "c++ compiler" FORCE)
set(CMAKE_LINKER "${AVRGCC_BIN}/avr-ld" CACHE PATH "linker" FORCE)
set(CMAKE_OBJCOPY "${AVRGCC_BIN}/avr-objcopy" CACHE PATH "objcopy" FORCE)
set(CMAKE_OBJDUMP "${AVRGCC_BIN}/avr-objdump" CACHE PATH "objdump" FORCE)
set(CMAKE_NM "${AVRGCC_BIN}/avr-nm" CACHE PATH "nm" FORCE)
set(CMAKE_AR "${AVRGCC_BIN}/avr-ar" CACHE PATH "ar" FORCE)
set(CMAKE_RANLIB "${AVRGCC_BIN}/avr-ranlib" CACHE PATH "ranlib" FORCE)
set(CMAKE_STRIP "${AVRGCC_BIN}/avr-strip" CACHE PATH "strip" FORCE)
set(AVRDUDE "${AVRDUDE_BIN}/avrdude" CACHE PATH "avrdude" FORCE)

#
# ターゲットマイコンに関する情報
#
set(AVR_MCU "atmega328p" CACHE STRING "The identifier of target microcontroller")
set(AVR_FCPU "16000000" CACHE STRING "The frequency of MCU")

#
# コンパイラの設定
#
include_directories(${AVRGCC_ROOT}/avr/include)
link_directories(${AVRGCC_ROOT}/avr/lib)

# コンパイラフラグ
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(OPTIMIZATION_FLAGS "-Os")
else()
    set(OPTIMIZATION_FLAGS "-Os -g")
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mmcu=${AVR_MCU} -DF_CPU=${AVR_FCPU} ${OPTIMIZATION_FLAGS}")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-exceptions")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fno-threadsafe-statics -fno-exceptions")

# リンカフラグ
set(LINKER_FLAGS "-lc")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINKER_FLAGS}")

#
# プログラマの設定
#
set(AVRDUDE_BAUDRATE "19200" CACHE STRING "The communication baudrate between PC and programmer")
set(AVRDUDE_PROGRAMMER "avrisp" CACHE STRING "The identifier of programmer")

#
# 書込みターゲット作成マクロ
#
macro(target_configure_for_avr target_name)
    # ターゲットが実行可能かを調べる
    get_target_property(target_type ${target_name} TYPE)
    if(target_type STREQUAL "EXECUTABLE")
        set(${target_name}_IS_EXECUTABLE TRUE)
    else()
        set(${target_name}_IS_EXECUTABLE FALSE)
    endif()

    if(${target_name}_IS_EXECUTABLE)
        # ビルド後、バイナリをダンプしてメモリ使用量を表示
        add_custom_command(TARGET ${target_name} POST_BUILD
            COMMAND ${CMAKE_OBJDUMP} -P mem-usage ${target_name}
        )

        # ポートが指定されている場合
        set(AVRDUDE_PORT "" CACHE STRING "Serial port with programmer attached")
        if(AVRDUDE_PORT)
            set(AVRDUDE_COMMON_FLAGS -C "${AVRDUDE_CONF}" -c "${AVRDUDE_PROGRAMMER}" -b "${AVRDUDE_BAUDRATE}" -P "${AVRDUDE_PORT}" -p "${AVR_MCU}")

            # フラッシュターゲットを追加
            add_custom_target(flash-${target_name}
                COMMAND ${AVRDUDE} ${AVRDUDE_COMMON_FLAGS} -U flash:w:${target_name}
                DEPENDS ${target_name}
            )

            # MCUのフューズ値を読むターゲットを追加
            add_custom_target(read-fuse
                COMMAND ${AVRDUDE} ${AVRDUDE_COMMON_FLAGS} -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h -U lock:r:-:h
            )
        else()
            message(NOTICE "Since no port for upload was specified (AVRDUDE_PORT is not set), creation of the flash target is skipped.")
        endif()
    endif()
endmacro()
