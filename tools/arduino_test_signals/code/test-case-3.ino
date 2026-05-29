// Test demo 3
#include <Arduino.h>

const int PULSE_PIN = 9;
const uint16_t N = 10000;

volatile int pulseCounter = 0;

void initTimer1() {
  // Setup Timer 1 (100kHz / 10us Periodic Interrupt)
  cli();          // Disable global interrupts during setup
  TCCR1A = 0;     // Set entire TCCR1A register to 0
  TCCR1B = 0;     // Set entire TCCR1B register to 0
  TCNT1  = 0;     // Initialize counter value to 0
  
  // Set compare match register for 20kHz increments
  // OCR1A = (16,000,000 / (1 * 10,000)) - 1 = 1599
  OCR1A = 1599; 
  // Turn on CTC (Clear Timer on Compare Match) mode
  TCCR1B |= (1 << WGM12);
    // Set CS10 bit for a prescaler of 1 (No Prescaling)
  TCCR1B |= (1 << CS10);  
    // Enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  sei();          // Re-enable global interrupts
}

// Timer 1 Interrupt Service Routine
ISR(TIMER1_COMPA_vect) {
  int num_pulses = 1;
  if (pulseCounter == 0) {
    num_pulses = 3;
  } 
  for (int i=0; i < num_pulses; i++) {
    digitalWrite(PULSE_PIN, HIGH);
    digitalWrite(PULSE_PIN, LOW);
  }
  pulseCounter++;
  if (pulseCounter >= N) {
    pulseCounter = 0;
  }
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println(F("Arduino Uno R3 - Test Case 3"));

  pinMode(PULSE_PIN, OUTPUT);
  digitalWrite(PULSE_PIN, LOW);
  // Initialize random seed using floating analog noise
  randomSeed(analogRead(0) ^ analogRead(1));
  initTimer1(); // initialize Timer 1
  sei();  // Enable global interrupts
  Serial.println("Pulse output pin: D9");
}

void loop() {
}
