cmake_minimum_required(VERSION 3.4.1)

# Add the C++ source file as a shared library named "habit_converter"
add_library(
    habit_converter
    SHARED
    ../../backend_core/habit_converter.cpp
)
