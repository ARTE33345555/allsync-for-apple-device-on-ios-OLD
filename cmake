cmake_minimum_required(VERSION 3.16)

project(device_ios_py
    LANGUAGES C CXX OBJC OBJCXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---- pybind11 ----
add_subdirectory(pybind11)

# ---- Python module ----
pybind11_add_module(device_ios
    python_bindings.cpp
    device_core.cpp
    ios_bridge.mm
)

target_include_directories(device_ios PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# ---- Apple frameworks ----
if(APPLE)
    target_link_libraries(device_ios PRIVATE
        "-framework Foundation"
        "-framework UIKit"
    )
endif()
