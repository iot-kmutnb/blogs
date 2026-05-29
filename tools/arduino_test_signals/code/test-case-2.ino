// Test demo 2
#include <Arduino.h>

constexpr int PULSE_PIN = 9;
constexpr int N = 10000;

// Volatile variables used within the high-speed ISR
volatile int glitchTargetIndex = 0;
volatile int pulseCounter = 0;

void initTimer1() {
  // Setup Timer 1 (100kHz / 10us Periodic Interrupt)
  cli();      // Disable global interrupts during setup
  TCCR1A = 0; // Set entire TCCR1A register to 0
  TCCR1B = 0; // Set entire TCCR1B register to 0
  TCNT1  = 0; // Initialize counter value to 0
    // Set compare match register for 20kHz increments
  // OCR1A = (16MHz / (1 * 20,000)) - 1 = 799
  OCR1A = 799; 
  // Turn on CTC (Clear Timer on Compare Match) mode
  TCCR1B |= (1 << WGM12);
    // Set CS10 bit for a prescaler of 1
  TCCR1B |= (1 << CS10);  
    // Enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  sei(); // Re-enable global interrupts
}

// Timer 1 Interrupt Service Routine (ISR)
ISR(TIMER1_COMPA_vect) {
  digitalWrite(PULSE_PIN, HIGH);
  if (pulseCounter == glitchTargetIndex) {
    delayMicroseconds(12);
  }
  digitalWrite(PULSE_PIN, LOW);
  pulseCounter++;
  if (pulseCounter >= N) {
    pulseCounter = 0;
    glitchTargetIndex = random(0, N);
  }
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println(F("Arduino Uno R3 - Test Case 2"));

  pinMode(PULSE_PIN, OUTPUT);
  digitalWrite(PULSE_PIN, LOW);
  // Initialize random seed
  randomSeed(analogRead(0) ^ analogRead(1));
  glitchTargetIndex = random(0, N);
  // Initialize timer1
  initTimer1();
  sei(); // Enable global interrupts
  Serial.println("Pulse output pin: D9");
}

void loop() {
}
