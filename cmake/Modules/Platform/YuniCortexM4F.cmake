# 
# YuniCortexM4F: CortexM4F hardfloat ABI 
#

cmake_minimum_required(VERSION 3.0.0)

set(CMAKE_SYSTEM_NAME YuniCortexM4F)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_CROSSCOMPILING TRUE)

if(CMAKE_TOOLCHAIN_FILE)
endif()

# Detect programs

find_program(CMAKE_AR arm-none-eabihf-ar)
find_program(CMAKE_C_COMPILER arm-none-eabihf-cc)
find_program(CMAKE_CXX_COMPILER arm-none-eabihf-c++)

set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

foreach(lang ASM C CXX)
    set(CMAKE_${lang}_COMPILE_OBJECT "<CMAKE_${lang}_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>")
    set(CMAKE_${lang}_CREATE_STATIC_LIBRARY "<CMAKE_AR> rc <TARGET> <LINK_FLAGS> <OBJECTS>")
    set(CMAKE_${lang}_LINK_EXECUTABLE "<CMAKE_${lang}_COMPILER> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")
    set(CMAKE_${lang}_COMPILER_WORKS TRUE)
endforeach()
