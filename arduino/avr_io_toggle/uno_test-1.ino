void setup() {
  pinMode( 13, OUTPUT );
}

void loop() { // period 6.76us. 3.2us+, 3.56us-, freq. 148kHz
  digitalWrite( 13, HIGH );  // 3.20us
  digitalWrite( 13, LOW );   // 3.56us
}
