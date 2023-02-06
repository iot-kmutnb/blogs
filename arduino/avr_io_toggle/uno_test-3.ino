void setup() {
  pinMode( 13, OUTPUT );
}
void loop() {
  static uint8_t state = 0;
  while(1) {
    digitalWrite( 13, state ^= 1 ); // period 6.12us, 3.00us+, 3.12us-, freq. 163kHz
  }
}
