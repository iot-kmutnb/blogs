// Test demo 1
#include <Arduino.h>

// Define the number of PWM channels
const int NUM_CHANNELS = 4;

// The default PWM frequency for the PWM  pins 3, 9, 10, and 11 is 490.2 Hz.
// or a period of 2040 usec

// Array of hardware PWM-capable pins (Valid for Arduino Uno/Nano)
constexpr int pwmPins[NUM_CHANNELS] = { 3, 9, 10, 11 };

#define DUTY_CYCLE(x)      (x * 255 / 100)
#define PULSE_WIDTH_US(x)  (x * 2040/ 255)

constexpr int dutyCycles[NUM_CHANNELS] = {
  DUTY_CYCLE(10), DUTY_CYCLE(25), DUTY_CYCLE(50), DUTY_CYCLE(75)
};

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println(F("Arduino Uno R3 - Test Case 1"));

  // Loop through the arrays to configure pins and apply PWM values
  for (int i = 0; i < NUM_CHANNELS; i++) {
    pinMode(pwmPins[i], OUTPUT);
    analogWrite(pwmPins[i], dutyCycles[i]);
    Serial.print(F("Arduino PWM pin: "));
    Serial.print(pwmPins[i]);
    Serial.print(F(", Pulse width [us]: "));
    Serial.println(PULSE_WIDTH_US(dutyCycles[i]));
  }
  Serial.println(F("PWM signal pins: D3,D9,D10,D11"));
}

void loop() {
  // emtpy
}
