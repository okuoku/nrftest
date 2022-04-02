#include <Arduino.h>

#include "FreeRTOS.h"
/* OpenOCD stub */
const volatile UBaseType_t uxTopUsedPriority = configMAX_PRIORITIES - 1U;

void setup() {
    (void) uxTopUsedPriority;
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(500);
  digitalWrite(LED_BUILTIN, LOW);
  delay(500);
}
