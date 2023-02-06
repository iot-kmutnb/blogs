void setup() {
  DDRB  |= (1 << 5);  // set DDRB bit 5 = 1
  PORTB |= (1 << 5);  // set PORTB bit 5 = 1
}

void loop() { // period = 500ns, freq. = 2MHz
  while(1) {
     PINB |= (1 << 5);  // toggle PB5 by writing 1 to PINB at bit 5  // 252ns+,248ns-
  }
}

