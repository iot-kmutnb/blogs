void setup() {
  DDRB |= _BV(5);
}

void loop() { // 12.3us+/- period 24.60us, freq=40.6kHz
  for ( float i=0; i < 1000.0f; i+=0.001f ) {
     PINB |= _BV(5);
  }
}
