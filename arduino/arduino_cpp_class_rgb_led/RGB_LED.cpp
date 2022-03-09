#include "RGB_LED.h"

RGB_LED::RGB_LED( uint8_t redPin, uint8_t greenPin, uint8_t bluePin, 
                  bool inverting ) 
{
  // save the Arduino pins for PWM output
  _pins[0] = redPin;
  _pins[1] = greenPin;
  _pins[2] = bluePin;
  _inverting = inverting;
  for ( uint8_t i=0; i < 3; i++ ) {
    pinMode( _pins[i], OUTPUT ); // use this pin as output
  }
  setColor( 0, 0, 0 ); // set initial color to zero (off)
}

void RGB_LED::setColor( uint8_t r, uint8_t g, uint8_t b ) {
  _rgb[0] = r;
  _rgb[1] = g;
  _rgb[2] = b;
  update();
}

void RGB_LED::setColor( uint32_t color ) {
  setColor( (color >> 16) & 0xff, 
            (color >>  8) & 0xff, 
             color & 0xff );
}

void RGB_LED::update() {
  uint8_t duty_cycle;
  for ( uint8_t i=0; i < 3; i++ ) {
    duty_cycle = (_inverting) ? (255 - _rgb[i]) : _rgb[i];
    analogWrite( _pins[i], duty_cycle );
  }
}
