void setup() {
  pinMode( 13, OUTPUT );
}
void loop() { // period 6.38us, 3.13us+, 3.24-us. freq. 157kHz
  static uint8_t state = 0;
  digitalWrite( 13, state ^= 1 );
}
