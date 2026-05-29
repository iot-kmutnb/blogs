// Test Case 5
// Signal A (D11): aperiodic pulses
//   Interval  : 1–2 ms random LOW time between consecutive pulses
//   Pulse width: 20 µs fixed HIGH
//
// Signal B (D12): response pulse following each A pulse
//   B always rises AFTER A has fallen (A is LOW when B rises).
//   The measured delay is from A's FALLING edge to B's RISING edge.
//
//   Normal : A-falling → B-rising delay =  3–15 µs  (< 20 µs)
//   Fault  : A-falling → B-rising delay = 21–100 µs (> 20 µs)
//   Pulse width: 20 µs fixed HIGH (same as A)
//   Fault rate : 1 per N_PULSES pulses, position randomised within window
//
// Sequence per pulse pair:
//   A → HIGH
//   wait PULSE_WIDTH_US (20 µs)
//   A → LOW   ← start of A-falling → B-rising delay (delay_fr)
//   wait delay_fr
//   B → HIGH
//   wait PULSE_WIDTH_US (20 µs)
//   B → LOW
//
// The µs-level sequence runs with interrupts disabled (cli/sei) to prevent
// Timer 0 ISR (~2 µs) from corrupting delay_fr.
// Timer 0 is kept enabled for delay() (1–2 ms inter-pulse intervals).
//
// All delayMicroseconds() arguments are ≥ 3 µs; the AVR library at 16 MHz
// special-cases us ≤ 1 (returns immediately with only call overhead).
//
// Pin choice:
//   D11 = PB3, D12 = PB4 - pure GPIO on Port B, no timer hardware function.

#include <Arduino.h>

constexpr uint8_t PIN_A = 11;   // PB3
constexpr uint8_t PIN_B = 12;   // PB4

// Fixed pulse width for both A and B
constexpr uint8_t PULSE_WIDTH_US = 20;   // µs

// A-falling → B-rising delay (delay_fr)
constexpr uint8_t  DELAY_NORMAL_MIN =   3;   // µs
constexpr uint8_t  DELAY_NORMAL_MAX =  15;   // µs  (< 20 µs limit)
constexpr uint8_t  DELAY_FAULT_MIN  =  21;   // µs  (> 20 µs)
constexpr uint8_t  DELAY_FAULT_MAX  = 100;   // µs

// Inter-pulse interval: A LOW time after B falls, before next A pulse
constexpr uint16_t INTERVAL_MIN_MS = 1;
constexpr uint16_t INTERVAL_MAX_MS = 2;

// Fault window: 1 fault per N_PULSES A-pulses (~2%)
constexpr uint16_t N_PULSES = 50;

uint16_t pulseCounter  = 0;
uint16_t faultPulseIdx = 0;

void setup() {
    Serial.begin(115200);
    delay(500);

    pinMode(PIN_A, OUTPUT);
    pinMode(PIN_B, OUTPUT);
    PORTB &= ~((1 << PB3) | (1 << PB4));   // A=LOW, B=LOW initially

    randomSeed(analogRead(0) ^ analogRead(1));
    faultPulseIdx = (uint16_t)random(0, N_PULSES);

    Serial.println(F("Arduino Uno R3 - Test Case 5"));
    Serial.println(F("A (D11): aperiodic, 1-2 ms interval, 20 us pulse width"));
    Serial.println(F("B (D12): follows A after A falls, delay 3-15 us (normal), >20 us (fault)"));
    Serial.println(F("B pulse width: 20 us | Fault: 1 per 50 pulses (~2%)"));
    Serial.flush();
}

void loop() {
    bool    fault    = (pulseCounter == faultPulseIdx);
    uint8_t delay_fr = fault
                       ? (uint8_t)random(DELAY_FAULT_MIN,  DELAY_FAULT_MAX  + 1)
                       : (uint8_t)random(DELAY_NORMAL_MIN, DELAY_NORMAL_MAX + 1);

    // Disable interrupts for the µs-level sequence.
    // Timer 0 ISR is deferred until sei(); it fires immediately after and
    // updates millis() correctly so the following delay() still works.
    cli();

    PORTB |=  (1 << PB3);           // A → HIGH
    delayMicroseconds(PULSE_WIDTH_US);
    PORTB &= ~(1 << PB3);           // A → LOW  (start of delay_fr)
    delayMicroseconds(delay_fr);    // A-falling → B-rising delay
    PORTB |=  (1 << PB4);           // B → HIGH  (delay_fr µs after A fell)
    delayMicroseconds(PULSE_WIDTH_US);
    PORTB &= ~(1 << PB4);           // B → LOW

    sei();   // re-enable interrupts before the ms-scale interval

    // Advance pulse counter; re-randomise fault position on window wrap
    if (++pulseCounter >= N_PULSES) {
        pulseCounter  = 0;
        faultPulseIdx = (uint16_t)random(0, N_PULSES);
    }

    // Random inter-pulse interval: 1–2 ms A LOW time before next A pulse
    delay(random(INTERVAL_MIN_MS, INTERVAL_MAX_MS + 1));
}
