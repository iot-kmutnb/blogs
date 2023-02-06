void setup() { 
  DDRB  |= (1 << 5);  // set DDRB bit 5 = 1
  PORTB |= (1 << 5);  // set PORTB bit 5 = 1
}

void loop() { // period=500s, 252ns+, 248ns-, freq. 2MHz
  asm volatile (
    "L0: sbi %0,%1     \n\t"    // [2C]
    "    nop           \n\t"    // [1C]
    "    nop           \n\t"    // [1C]
    "    cbi %0,%1     \n\t"    // [2C]
    "    rjmp L0       \n\t"    // [2C]
    :: "I" (_SFR_IO_ADDR(PORTB)), "I" (PORTB5)
  );
}
