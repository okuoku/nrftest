execute_process(
    COMMAND ${CMAKE_COMMAND}
    -DROOT=${CMAKE_CURRENT_LIST_DIR}
    -DPATH=Adafruit_nRF52_Arduino/cores/nRF5
    -DTYPE=core
    -P ${CMAKE_CURRENT_LIST_DIR}/gen_arduino_srctab.cmake
    OUTPUT_FILE core.cmake
    ERROR_FILE core.cmake
    )

execute_process(
    COMMAND ${CMAKE_COMMAND}
    -DREPO=Adafruit_nRF52
    -DROOT=${CMAKE_CURRENT_LIST_DIR}
    -DPATH=Adafruit_nRF52_Arduino/libraries
    -DTYPE=lib
    -P ${CMAKE_CURRENT_LIST_DIR}/gen_arduino_srctab.cmake
    OUTPUT_FILE libs.cmake
    ERROR_FILE libs.cmake
    )

