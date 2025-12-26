cmake_minimum_required(VERSION 3.16)

project(DeviceIOS
    LANGUAGES C CXX OBJC OBJCXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---- библиотека ----
add_library(device_ios STATIC
    device_ios.cpp
    ios_bridge.mm
)

# ---- include ----
target_include_directories(device_ios PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# ---- Apple frameworks ----
if(APPLE)
    target_link_libraries(device_ios
        "-framework Foundation"
        "-framework UIKit"
    )
endif()
