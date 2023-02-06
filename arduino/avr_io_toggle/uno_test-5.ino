void setup() {
  DDRB  |= (1 << 5);  // set DDRB bit 5 = 1
  PORTB |= (1 << 5);  // set PORTB bit 5 = 1
}

void loop() { // period 750, 376ns+, 374ns-, freq. = 1.33MHz
  PINB |= (1 << 5);  // toggle PB5 by writing 1 to PINB at bit 5  // 375ns
}

