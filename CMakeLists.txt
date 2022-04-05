set(SERIAL "/dev/ttyS5")

# 
# Prerequisite: nrfutil from
# https://github.com/adafruit/Adafruit_nRF52_nrfutil
#

cmake_minimum_required(VERSION 3.10)

project(nrftest C ASM CXX)

include(./core.cmake)
include(./libs.cmake)

set(libs ${arduinolibs_Adafruit_nRF52})

foreach(l ${libs})
    include_directories(${arduinolib_${l}_incs})
endforeach()

list(REMOVE_ITEM libs
    BLEHomekit # Depends Bluefruit_FileIO
    )

find_program(OBJCOPY arm-none-eabihf-objcopy REQUIRED)
find_program(NRFUTIL adafruit-nrfutil REQUIRED)


set(cpuflags "-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(cflags "-Wall -Wextra -Werror=return-type -Wno-unused-parameter -Wno-missing-field-initializers -Wno-pointer-arith -Ofast -g -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 ${cpuflags}")
set(CMAKE_C_FLAGS "-std=gnu11 ${cflags}")
set(CMAKE_ASM_FLAGS "${cpuflags} -mabi=aapcs")
set(CMAKE_CXX_FLAGS "${cflags} -std=gnu++11 -fno-rtti -fno-exceptions")
# FIXME: --specs=nano.specs ?? Maybe we need stdc++_nano etc?
set(CMAKE_EXE_LINKER_FLAGS
    "-L ${CMAKE_CURRENT_LIST_DIR}/Adafruit_nRF52_Arduino/cores/nRF5/linker -Wl,-T -Wl,${CMAKE_CURRENT_LIST_DIR}/Adafruit_nRF52_Arduino/cores/nRF5/linker/nrf52840_s140_v6.ld -Wl,--gc-sections -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -Wl,--wrap=malloc -Wl,--wrap=free -Wl,--build-id=none --specs=nosys.specs")

add_definitions(
    # Arduino
    -DF_CPU=64000000
    -DARDUINO_SSCI_ISP1807_MICRO_BOARD
    -DARDUINO=10803 # 1.8.3
    -DARDUINO_ARCH_NRF52
    -DARDUINO_ARCH_NRF52_ADAFRUIT
    -DARDUINO_BSP_VERSION=\"1.3.0\"
    # USB
    -DUSBCON
    -DUSE_TINYUSB
    # Board
    -DUSB_VID=0x2786
    -DUSB_PID=0x920D
    "-DUSB_MANUFACTURER=\"Switch Science, Inc.\""
    "-DUSB_PRODUCT=\"SSCI ISP1807 Micro Board\""
    -DNRF52840_XXAA
    # Debug
    -DCFG_DEBUG=1
    -DCFG_LOGGER=0
    -DCFG_SYSVIEW=0
    # NRF
    -DSOFTDEVICE_PRESENT
    -DARDUINO_NRF52_ADAFRUIT 
    -DNRF52_SERIES 
    -DDX_CC_TEE 
    -DLFS_NAME_MAX=64
    )

include_directories(
    Adafruit_nRF52_Arduino/cores/nRF5
    Adafruit_nRF52_Arduino/cores/nRF5/nordic
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx/hal
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx/mdk
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx/soc
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx/drivers/include
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/nrfx/drivers/src
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/softdevice/s140_nrf52_6.1.1_API/include
    Adafruit_nRF52_Arduino/cores/nRF5/nordic/softdevice/s140_nrf52_6.1.1_API/include/nrf52
    Adafruit_nRF52_Arduino/cores/nRF5/freertos/Source/include
    Adafruit_nRF52_Arduino/cores/nRF5/freertos/config
    Adafruit_nRF52_Arduino/cores/nRF5/freertos/portable/GCC/nrf52
    Adafruit_nRF52_Arduino/cores/nRF5/freertos/portable/CMSIS/nrf52

    SWITCHSCIENCE_Arduino_Board_Package/nrf52/variants/isp1807microboard

    Adafruit_nRF52_Arduino/cores/nRF5/sysview/Config
    Adafruit_nRF52_Arduino/cores/nRF5/sysview/SEGGER
    Adafruit_nRF52_Arduino/libraries/Adafruit_TinyUSB_Arduino/src/arduino
    CMSIS_5/CMSIS/Core/Include

    Adafruit_Sensor
    Adafruit_NeoPixel
    Adafruit_AHRS/src
    Adafruit_Sensor_Calibration
    SdFat/src
    ArduinoJson/src
    )


foreach(l ${libs})
    add_library(${l} STATIC ${arduinolib_${l}_srcs})
endforeach()

add_library(ArduinoCore STATIC
    SWITCHSCIENCE_Arduino_Board_Package/nrf52/variants/isp1807microboard/variant.cpp
    ${arduinolib_core_srcs})

add_library(target_main blink.cpp)
add_executable(target dummy.cpp)
target_link_options(target PRIVATE
    #-Wl,--print-gc-sections
    -Wl,--whole-archive
    -Wl,--start-group
    $<TARGET_FILE:Adafruit_TinyUSB_Arduino>
    $<TARGET_FILE:ArduinoCore>
    $<TARGET_FILE:target_main>
    -Wl,--end-group
    -Wl,--no-whole-archive
    )
add_dependencies(target target_main ArduinoCore Adafruit_TinyUSB_Arduino)

#target_link_libraries(target 
#    )

add_custom_command(TARGET target
    POST_BUILD
    # generate binary
    COMMAND ${OBJCOPY} -O binary $<TARGET_FILE:target> $<TARGET_FILE:target>.bin
    # generate ihex
    COMMAND ${OBJCOPY} -O ihex $<TARGET_FILE:target> $<TARGET_FILE:target>.hex
    # generate DFU package
    COMMAND ${NRFUTIL} dfu genpkg --dev-type 0x52 --sd-req 0x00B6
    --application $<TARGET_FILE:target>.hex $<TARGET_FILE:target>.dfu.zip
    )

add_custom_target(write
    COMMAND ${NRFUTIL} --verbose dfu serial -pkg $<TARGET_FILE:target>.dfu.zip -p ${SERIAL} -b 115200 --singlebank
    USES_TERMINAL
    )
