# cmake-avr

## Overview

CMake toolchain for AVR microcontroller

## Usage

You can use this toolchain by some ways:

 1. Configure project only for AVR (always use toolchain when build project)
 2. Configure project for cross-platform software (use toolchain only if build for AVR)

### Before you use...

This repository depends on [arduino-cli](https://github.com/arduino/arduino-cli), and need to install `arduino:avr` core before you use it:

```
arduino-cli core install arduino:avr
```

### 1. Always use toolchain when build project

If you always want to use AVR toolchain, please insert following lines into `CMakeLists.txt`.

**NOTE:** Please insert them before `project()` statement!

```cmake
# mcu settings
set(AVR_MCU "atmega328p" CACHE STRING "The name of target microcontroller")
set(AVR_FCPU 16000000 CACHE STRING "The frequency of target")

# programmer settings
set(AVRDUDE_PROGRAMMER "avrisp" CACHE STRING "The name of programmer")
set(AVRDUDE_BAUDRATE 19200 CACHE STRING "Baudrate used for communicate between PC and programmer")

# fetch and enable AVR toolchain
include(FetchContent)
FetchContent_Declare(
    avr_toolchain
    GIT_REPOSITORY https://github.com/Enchan1207/cmake-avr
    GIT_TAG v0.1.0
)
FetchContent_Populate(avr_toolchain)
set(CMAKE_TOOLCHAIN_FILE "${avr_toolchain_SOURCE_DIR}/cmake/avr_toolchain.cmake")
```

### 2. Use toolchain only if build for AVR

If your project is developed as cross-platform software, add `--toolchain=` options to cmake when configure.

```
cmake .. --toolchain=/path/to/avr_toolchain.cmake
```

It can be able to build your project for AVR without making any changes to `CMakeLists.txt`.

### Custom macros

This toolchain provides custom macros named `target_configure_for_avr()`. It can use like this:

```cmake
add_executable(main)
target_sources(main PRIVATE
    main.cpp
)

# If your project is not only for AVR,
# please check if BUILD_FOR_AVR is defined and its value is `true`
if(${BUILD_FOR_AVR})
    target_configure_for_avr(main)
endif()
```

This macro adds the following custom targets and commands to your target:

 - Flash target:  
   Custom target named `flash-{target_name}` for flashing.
   If you execute this target, built programms will be flashed to microcontroller by `avrdude`.
 - Memory usage confirmation:  
   After the target has finished building, the memory usage calculated by `avr-objdump` is displayed to console.

## Note

Currently, this toolchain **not supports** Arduino headers, libraries, or programms(.ino).

## License

This repository is published under [MIT License](LICENSE).
