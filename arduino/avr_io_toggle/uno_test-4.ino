void setup() {
  DDRB  |=  (1 << 5);  // set DDRB bit 5 = 1 (output direction)
  PORTB &= ~(1 << 5);  // clear bit PB5 (output low at PB5)
}

void loop() { // period 500 us, freq = 2MHz
  PORTB |=  (1 << 5);  // set bit PB5 (output high at PB5)  // 128ns+
  PORTB &= ~(1 << 5);  // clear bit PB5 (output low at PB5) // 372ns-
}
