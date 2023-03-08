#
# CMake AVR toolchain with arduino-cli
#
# 2023 @Enchan1207
#
cmake_minimum_required(VERSION 3.0)

#
# ツールチェーン内部で使用するコマンドの構成
#

# arduino-cliを探す
set(ARDUINOCLI_ROOT "")
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

# avr-gcc, avrdudeのバリアントを取得し、最新版のパスを変数に設定
file(GLOB AVRGCC_VARIANTS ${ARDUINOCLI_ROOT}/packages/arduino/tools/avr-gcc/*)
list(SORT AVRGCC_VARIANTS ORDER DESCENDING)
list(GET AVRGCC_VARIANTS 0 AVRGCC_ROOT)
if(NOT AVRGCC_ROOT)
    message(FATAL_ERROR "The command avr-gcc not found.")
endif()
set(AVRGCC_BIN ${AVRGCC_ROOT}/bin)

file(GLOB AVRDUDE_VARIANTS ${ARDUINOCLI_ROOT}/packages/arduino/tools/avrdude/*)
list(SORT AVRDUDE_VARIANTS ORDER DESCENDING)
list(GET AVRDUDE_VARIANTS 0 AVRDUDE_ROOT)
if(NOT AVRDUDE_ROOT)
    message(FATAL_ERROR "The command avrdude not found.")
endif()

# ついでにavrdudeの初期設定
set(AVRDUDE_BIN ${AVRDUDE_ROOT}/bin)
set(AVRDUDE_CONF ${AVRDUDE_ROOT}/etc/avrdude.conf)
if(NOT EXISTS ${AVRDUDE_CONF})
    message(FATAL_ERROR "The configuration file for avrdude (avrdude.conf) not found.")
endif()

#
# CMakeが使用するコマンドの構成
#

# AVR向けのクロスコンパイルであることを明示する
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_CROSS_COMPILING 1)

# 各コマンドのパスを設定する
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
# 環境設定
#

# コンパイラフラグ、最適化フラグの設定
set(COMMON_FLAGS "-mmcu=${AVR_MCU} -DF_CPU=${AVR_FCPU} -fno-threadsafe-statics -fno-exceptions")
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(OPTIMIZATION_FLAGS "-Os")
else()
    set(OPTIMIZATION_FLAGS "-Os -g")
endif()
set(COMPILER_FLAGS "${COMMON_FLAGS} ${OPTIMIZATION_FLAGS}")
set(LINKER_FLAGS "${COMMON_FLAGS} -lc")

# avrdudeの設定 (ボーレートとかプログラマとか)
if(NOT AVRDUDE_BAUDRATE)
    set(AVRDUDE_BAUDRATE 19200)
endif()
if(NOT AVRDUDE_PROGRAMMER)
    set(AVRDUDE_PROGRAMMER "avrisp")
endif()

#
# AVR用ターゲット作成マクロ
#

# ターゲットをAVR向けに構成する
macro(target_configure_for_avr target_name)
    if(NOT AVR_MCU OR NOT AVR_FCPU)
        message(FATAL_ERROR "Please specify AVR_MCU (e.g. \"atmega328p\") and AVR_FCPU (e.g. \"16000000\").")
    endif()

    set_target_properties(${target_name} PROPERTIES
        COMPILE_FLAGS "${COMPILER_FLAGS}"
        LINK_FLAGS "${LINKER_FLAGS}"
    )

    target_include_directories(${target_name} PUBLIC
        ${AVRGCC_ROOT}/avr/include
    )

    target_link_directories(${target_name} PUBLIC
        ${AVRGCC_ROOT}/avr/lib
    )
endmacro()

# AVR版 add_executable
macro(add_executable_avr target_name)
    add_executable(${target_name})
    target_configure_for_avr(${target_name})

    # ビルド後、バイナリをダンプしてメモリ使用量を表示
    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -P mem-usage ${target_name}
    )

    # ポートが指定されている場合
    if(DEFINED AVRDUDE_PORT)
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
        message(WARNING "Since no port for upload was specified (AVRDUDE_PORT is not set), creation of the flash target is skipped.")
    endif()
endmacro()

# AVR版 add_library
macro(add_library_avr target_name)
    add_library(${target_name})
    target_configure_for_avr(${target_name})
endmacro()
