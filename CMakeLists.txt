cmake_minimum_required(VERSION 3.12)

# スタンドアロンで動作する場合はこの子自身をprojectとする
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    project(cmake_avr_sdk
        VERSION 1.0.0
        DESCRIPTION "AVR microcontroller SDK"
        LANGUAGES C CXX
    )
    
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Release)
    endif()
    
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/libs/CMakeLists.txt")
        set(AVR_SDK_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
        add_subdirectory(libs)
    endif()
endif()

# モジュール検索パスに自身を追加
set(AVR_SDK_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake" CACHE PATH "AVR SDK CMake modules directory")
list(APPEND CMAKE_MODULE_PATH "${AVR_SDK_CMAKE_DIR}")
