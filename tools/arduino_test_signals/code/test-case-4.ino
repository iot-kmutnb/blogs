// Test Case 4
// Two complementary non-overlapping 20 kHz signals: A on D11, B on D12.
//
// Normal operation:
//   A and B are strictly complementary. At every transition a dead time of
//   DEAD_TIME_US is inserted where both signals are LOW, guaranteeing A and B
//   are never HIGH simultaneously under normal conditions.
//
//   A-rising  edge sequence : B → LOW,  wait DEAD_TIME_US,  A → HIGH
//   A-falling edge sequence : A → LOW,  wait DEAD_TIME_US,  B → HIGH
//
// Fault simulation:
//   Once per 10 000 full periods (≈ every 500 ms) one A-rising edge is
//   corrupted: A goes HIGH while B is still HIGH, creating an overlap of
//   OVERLAP_US where both signals are HIGH. B then goes LOW.
//   This simulates a dead-band timing failure (e.g. shoot-through in an
//   H-bridge gate drive).
//
// Timer 1 (CTC, no prescaler) fires at 40 kHz (every 25 µs).
// Each ISR call = one half-period; A and B transition at 20 kHz.
//
// Pin choice - why NOT D8/D9/D10:
//   D9  = PB1 = OC1A  - Timer 1 output-compare A
//   D10 = PB2 = OC1B  - Timer 1 output-compare B
//   D8  = PB0 = ICP1  - Timer 1 input-capture
//   Even with TCCR1A = 0 the hardware compare latch can briefly fight ISR
//   PORTB writes, causing one pin to glitch or appear dead.
//   D11 (PB3) and D12 (PB4) have no Timer 1 function and are free of this.
//
// Jitter suppression:
//   Timer 0 overflow ISR (millis/micros, ~every 1.024 ms) is disabled after
//   setup() so Timer 1 fires with hardware-only latency (~200 ns, no competing
//   ISR). Side-effect: millis() / micros() / delay() stop after setup().

#include <Arduino.h>

// Pin assignment
// D11 = PB3, D12 = PB4 - no Timer 1 hardware function, adjacent Port B pins.
constexpr uint8_t PIN_A = 11;   // PB3
constexpr uint8_t PIN_B = 12;   // PB4

// Timer 1 configuration
// OCR1A = (F_CPU / prescaler / ISR_rate) − 1
//       = (16 000 000 / 1 / 40 000) − 1 = 399
constexpr uint16_t OCR1A_VAL = 399;

// Dead time inserted at every transition (both A and B LOW, normal case).
// Must be >= 2: the AVR Arduino implementation of delayMicroseconds() special-
// cases us <= 1 at 16 MHz and returns immediately (only function-call overhead
// ~11 cycles / ~700 ns), so DEAD_TIME_US = 1 produces no real delay loop and
// reads as ~700 ns on a scope instead of 1 µs.
constexpr uint8_t DEAD_TIME_US = 2;   // µs  (~2 µs measured on scope)

// Overlap duration injected at the fault edge (both A and B HIGH, fault case)
constexpr uint8_t OVERLAP_US = 5;     // µs  (clearly distinct from dead time)

// Window: 10 000 full periods = 20 000 half-periods ≈ 500 ms at 20 kHz
constexpr uint16_t N_HALF = 20000;

// ISR-shared state
volatile bool     stateA        = false;
volatile uint16_t halfCounter   = 0;
volatile uint16_t glitchHalfIdx = 0;   // always even → A-rising half-period

void initTimer1() {
    cli();
    TCCR1A = 0;               // OC1A/OC1B pins disconnected (software control)
    TCCR1B = 0;
    TCNT1  = 0;
    OCR1A  = OCR1A_VAL;
    TCCR1B |= (1 << WGM12);   // CTC mode (clear on compare match)
    TCCR1B |= (1 << CS10);    // Prescaler = 1 (no prescaling)
    TIMSK1 |= (1 << OCIE1A);  // Enable Timer1 compare-A interrupt
    sei();
}

// ISR: fires every 25 µs (40 kHz).
// Both pins are driven from the same ISR body so their relative timing is
// deterministic regardless of Timer 0 jitter (Timer 0 is disabled in setup).
//
// Normal path timing (per half-period):
//   dead time branch : B or A → LOW, 1 µs busy-wait, A or B → HIGH  (~1.5 µs)
// Fault path timing (A-rising only, once per window):
//   A → HIGH, 3 µs busy-wait, B → LOW                               (~3.5 µs)
// Both paths complete well within the 25 µs half-period budget.
ISR(TIMER1_COMPA_vect) {
    stateA = !stateA;

    if (stateA) {
        // A-rising: transition (A=LOW, B=HIGH) → (A=HIGH, B=LOW)
        if (halfCounter == glitchHalfIdx) {
            // Fault: A rises before B falls - both HIGH for OVERLAP_US
            PORTB |=  (1 << PB3);           // A → HIGH  (B still HIGH → overlap)
            delayMicroseconds(OVERLAP_US);
            PORTB &= ~(1 << PB4);           // B → LOW   (overlap ends)
        } else {
            // Normal: B falls, dead time (both LOW), then A rises
            PORTB &= ~(1 << PB4);           // B → LOW
            delayMicroseconds(DEAD_TIME_US);
            PORTB |=  (1 << PB3);           // A → HIGH
        }
    } else {
        // A-falling: transition (A=HIGH, B=LOW) → (A=LOW, B=HIGH)
        // Always normal - fault injected on A-rising edges only
        PORTB &= ~(1 << PB3);               // A → LOW
        delayMicroseconds(DEAD_TIME_US);
        PORTB |=  (1 << PB4);               // B → HIGH
    }

    // Advance window counter; re-randomise glitch position on wrap.
    // Constrain to even indices so the glitch always falls on an A-rising edge
    // (halfCounter 0, 2, 4, … correspond to stateA becoming true).
    if (++halfCounter >= N_HALF) {
        halfCounter   = 0;
        glitchHalfIdx = (uint16_t)(random(0, (long)(N_HALF / 2))) * 2;
    }
}

void setup() {
    Serial.begin(115200);
    delay(1000);

    pinMode(PIN_A, OUTPUT);
    pinMode(PIN_B, OUTPUT);

    // Initial state: A = LOW, B = HIGH (complementary pair)
    PORTB &= ~(1 << PB3);
    PORTB |=  (1 << PB4);
    stateA = false;

    // Seed PRNG from two floating ADC channels; pick first glitch position.
    // Even index only so the fault always lands on an A-rising half-period.
    randomSeed(analogRead(0) ^ analogRead(1));
    glitchHalfIdx = (uint16_t)(random(0, (long)(N_HALF / 2))) * 2;

    // Print configuration - must happen before Timer 0 is disabled and before
    // initTimer1() starts the ISR (Serial relies on USART interrupts, not
    // Timer 0, but delay() in Serial internals requires Timer 0 to be alive).
    Serial.println(F("Arduino Uno R3 - Test Case 4"));
    Serial.println(F("Signal A : D11  (PB3)"));
    Serial.println(F("Signal B : D12  (PB4)  -- complement of A"));
    Serial.println(F("Frequency: 20 kHz"));
    Serial.print  (F("Dead time (both LOW)    : "));
    Serial.print  (DEAD_TIME_US);
    Serial.println(F(" us  (every transition, normal)"));
    Serial.print  (F("Fault overlap (both HIGH): "));
    Serial.print  (OVERLAP_US);
    Serial.println(F(" us  (once per 10 000 periods, ~500 ms)"));

    // Drain TX buffer, then disable Timer 0 overflow interrupt (millis heartbeat).
    // Must be called after all delay() and Serial I/O.
    // After this point millis() / micros() / delay() stop advancing - acceptable
    // since loop() is empty. delayMicroseconds() is unaffected (busy-wait only).
    Serial.flush();
    TIMSK0 &= ~(1 << TOIE0);
    initTimer1();
}

void loop() {
}
