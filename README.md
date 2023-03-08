# cmake-avr

## Overview

CMake toolchain for AVR microcontroller

## Usage

### 0. Preparation

This repository depends on [arduino-cli](https://github.com/arduino/arduino-cli), and need to install `arduino:avr` core before you use it:

```
arduino-cli core install arduino:avr
```

### 1. Install AVR toolchain to your project

Add the following statements to `CMakeLists.txt` located in the project root:

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

By addition, the AVR toolchain is installed to your project as CMake dependency and you'll become able to use the macros shown below:

 - `target_configure_for_avr(the_name_of_target)`  
   Configure your target for AVR. Specifically, include directories and compilation options are added or changed.  

 - `add_executable_avr(the_name_of_target)`  
   Make your target executable on AVR. This macro invokes `target_configure_for_avr` internally.

 - `add_library_avr(the_name_of_target)`  
   Configure your target as a library for AVR. This macro invokes `target_configure_for_avr` internally.

Additionally, the custom targets will be added:

 - `flash-{target_name}` : Flash specified target to your MCU. This target will be created only if you set variable `AVRDUDE_PORT`.
 - `read-fuse` : Read values of fusebits and output to console.

### 2. Code, and create target for AVR

First, write code for AVR. For example...

```C
//
// main.cpp
//
#include <avr/io.h>
#include <util/delay.h>

int main() {
    DDRB = 0xFF;
    PORTB = 0x55;
    while (true) {
        PORTB ^= 0xFF;
        _delay_ms(500);
    }
    return 0;
}
```

Next, prepare `CMakeLists.txt`:

```cmake
#
# CMakeLists.txt
#
cmake_minimum_required(VERSION 3.0)

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

#
# project configuration
#
project(test
    VERSION 0.1.0
    DESCRIPTION "parse and evaluate formula"
    LANGUAGES C CXX
)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable_avr(main)
target_sources(main PRIVATE
    main.cpp
)
```

The compositon of project directory should look like this:

```
.
├── CMakeLists.txt
└── main.cpp
```

### 3. Build

Create build directory and move:

```
mkdir build
cd build
```

Connect programmer to your PC, and configure CMake:

```
cmake .. -DAVRDUDE_PORT=/dev/device_name_of_programmer
```

Build:

```
cmake --build .
```

### 4. Flash

When project is successfully configured and built, the target for flashing will be created.

```
cmake --build . --target flash-main
```

```
avrdude: AVR device initialized and ready to accept instructions

Reading | ################################################## | 100% 0.05s

avrdude: Device signature = 0x1e950f (probably m328p)
avrdude: NOTE: "flash" memory has been specified, an erase cycle will be performed
         To disable this feature, specify the -D option.
avrdude: erasing chip
avrdude: reading input file "main"
avrdude: input file main auto detected as ELF
avrdude: writing flash (166 bytes):

Writing | ################################################## | 100% 0.32s

avrdude: 166 bytes of flash written
avrdude: verifying flash memory against main:
avrdude: load data flash data from input file main:
avrdude: input file main auto detected as ELF
avrdude: input file main contains 166 bytes
avrdude: reading on-chip flash data:

Reading | ################################################## | 100% 0.19s

avrdude: verifying ...
avrdude: 166 bytes of flash verified

avrdude done.  Thank you.
```

OK, Now your code is running on your AVR!

## Note

Currently, this toolchain **not supports** Arduino headers, libraries, or programms(.ino).

## License

This repository is published under [MIT License](LICENSE).
