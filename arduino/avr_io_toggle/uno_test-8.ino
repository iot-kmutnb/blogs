void setup() { 
  DDRB  |= (1 << 5);  // set DDRB bit 5 = 1
  PORTB |= (1 << 5);  // set PORTB bit 5 = 1
}

void loop() { // period=500ns, 252ns+, 248ns-, freq. 2MHz
  asm volatile (
    "L0: sbi %0,%1    \n\t"   // [2C]
    "    rjmp L0      \n\t"   // [2C]
    :: "I" (_SFR_IO_ADDR(PINB)), "I" (PINB5)
  );
}

// with one nop added: period=624ns, 312ns+, 312ns-, freq. 1.60MHz