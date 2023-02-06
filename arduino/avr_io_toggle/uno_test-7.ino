void setup() { // period 500ns, 252ns+, 248ns-, freq. 2MHz
  DDRB  |= (1 << 5);  // set DDRB bit 5 = 1
  PORTB |= (1 << 5);  // set PORTB bit 5 = 1
}

void loop() {
  asm volatile (
    "L0: sbi %0,%1   \n\t"   // [2C] set bit 5 in register PORTB
    "    cbi %0,%1   \n\t"   // [2C] clear bit 5 in register PORTB
    "    rjmp L0     \n\t"   // [2C] relative jump (backward) to label 0:
    :: "I" (_SFR_IO_ADDR(PORTB)), "I" (PORTB5) 
  );
 // "I": used as input arguments %0 and %1 respectively
}