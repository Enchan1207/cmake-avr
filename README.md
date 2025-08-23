# cmake-avr

## Overview

CMake toolchain for AVR microcontroller

## Requirements

- CMake >= 3.23 (to use presets. If you use this without presets, CMake >= 3.12 is acceptable.)
- AVR compiler (see section [Appendix: How to install a compiler](#appendix-how-to-install-a-compiler).)

## Usage

1. Clone this repository.

   ```sh
   git clone https://github.com/Enchan1207/cmake-avr
   ```

2. Set environment variable `AVR_SDK_PATH` to it.

   ```sh
   export AVR_SDK_PATH='/path/to/cmake-avr'
   ```

3. Configure `CMakePresets.json` .
   > [!WARNING]
   >
   > To use [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html), CMake >= 3.23 is required.

   ```json
   {
       "version": 10,
       "cmakeMinimumRequired": {
           "major": 3,
           "minor": 12,
           "patch": 0
       },
       "configurePresets": [
           {
               "name": "target",
               "generator": "Ninja",
               "binaryDir": "${sourceDir}/build/${presetName}",
               "cacheVariables": {
                   "AVR_MCU": "attiny85",
                   "AVR_FCPU": "8000000"
               },
               "toolchainFile": "$env{AVR_SDK_PATH}/cmake/avr_toolchain.cmake"
           }
       ],
       "buildPresets": [
           {
               "name": "target",
               "configurePreset": "target"
           }
       ]
   }
   ```

4. (optional) Add `target_configure_for_avr` for your target in `CMakeLists.txt`.
   it provides memory-usage and `.hex` file output to specified target.

   ```cmake
   add_executable(main_target)

   # some configuration...

   target_configure_for_avr(main_target)
   ```

## Configuration options

This toolchain provides options: `AVR_MCU` and `AVR_FCPU`.
It will be passed to commands and can be set at configure (`cmake ...`) or at `CMakePresets.json`.

## Appendix: How to install a compiler

AVR compilers can be installed from [microchip](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio/gcc-compilers) or [HomeBrew](https://github.com/osx-cross/homebrew-avr).

## License

This repository is published under [MIT License](LICENSE).
