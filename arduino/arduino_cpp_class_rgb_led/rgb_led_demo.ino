#include "RGB_LED.h"

#define RED_PIN   (9)
#define GREEN_PIN (10)
#define BLUE_PIN  (11)

RGB_LED led( RED_PIN, GREEN_PIN, BLUE_PIN, false );

uint32_t COLORS[] = { 
   0xff0000, 0x00ff00, 0x0000ff, 
   0xffff00, 0x00ffff, 0xff00ff, 0xaa8e55, 0, };

void setup() {
   // empty
}

void loop() {
  int n = sizeof(COLORS) / sizeof(COLORS[0]);
  for (int i=0; i < n; i++ ) {
    led.setColor( COLORS[i] ); // change color
    delay(1000);
  }  
}
