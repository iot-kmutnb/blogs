void setup() {
  DDRB |= _BV(5);
}

void loop() { // 500ns+, 495ns-, period 995ns, freq=1MHz
  for ( uint32_t i=0; i < 1000000; i+=1 ) {
     PINB |= _BV(5);
  }
}
