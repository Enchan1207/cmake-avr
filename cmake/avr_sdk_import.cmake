#
# AVR SDK initialization module
#
# 2025 @Enchan1207
#

if(NOT DEFINED AVR_SDK_PATH)
    if(DEFINED ENV{AVR_SDK_PATH})
        set(AVR_SDK_PATH $ENV{AVR_SDK_PATH})
    else()
        message(FATAL_ERROR "AVR_SDK_PATH is not set. Please set environment variable AVR_SDK_PATH to point to cmake-avr directory.")
    endif()
endif()

# Ensure AVR_SDK_PATH points to a valid directory
if(NOT EXISTS "${AVR_SDK_PATH}")
    message(FATAL_ERROR "AVR_SDK_PATH does not exist: ${AVR_SDK_PATH}")
endif()

if(NOT EXISTS "${AVR_SDK_PATH}/cmake/avr_toolchain.cmake")
    message(FATAL_ERROR "Invalid AVR_SDK_PATH: toolchain file not found at ${AVR_SDK_PATH}/cmake/avr_toolchain.cmake")
endif()

function(avr_sdk_init)
    if(DEFINED AVR_SDK_INITIALIZED)
        return()
    endif()
    
    message(STATUS "Initializing AVR SDK from: ${AVR_SDK_PATH}")
    
    # ソースディレクトリをライブラリとして追加
    set(AVR_SDK_LIBRARY_DIR "${AVR_SDK_PATH}/src")
    if(EXISTS "${AVR_SDK_LIBRARY_DIR}/CMakeLists.txt")
        add_subdirectory("${AVR_SDK_LIBRARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/avr_sdk_libs")
    else()
        message(WARNING "AVR SDK libraries not found at ${AVR_SDK_LIBRARY_DIR}")
    endif()
    
    # インクルードディレクトリを追加
    set(AVR_SDK_INCLUDE_DIR "${AVR_SDK_PATH}/include")
    if(EXISTS "${AVR_SDK_INCLUDE_DIR}")
        include_directories("${AVR_SDK_INCLUDE_DIR}")
    else()
        message(WARNING "AVR SDK include directory not found at ${AVR_SDK_INCLUDE_DIR}")
    endif()
    
    # Mark as initialized
    set(AVR_SDK_INITIALIZED TRUE PARENT_SCOPE)
    set(AVR_SDK_INITIALIZED TRUE)
    
    message(STATUS "AVR SDK initialization complete")
endfunction()
