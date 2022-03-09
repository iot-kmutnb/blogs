#ifndef _RGB_LED_H
#define _RGB_LED_H

#include <Arduino.h>
#include <inttypes.h>

// This class implements a color controller for a single RGB LED
// that can change its color by adjust the duty cycles of
// three PWM signals used to control that LED.

class RGB_LED {
  public:
    // class constructor
    RGB_LED( uint8_t redPin, uint8_t greenPin, uint8_t bluePin, 
             bool inverting=false );
    // instance member methods
    void setColor( uint32_t color );  // set the RGB color
    void setColor( uint8_t r, uint8_t g, uint8_t b ); // set the RGB color

  private:
    // private member method
    void update();
    // private member fields
    uint8_t _pins[3], _rgb[3];
    bool _inverting; // inverse the PWM output?
}; // end of class (don't forget the semicolon)

#endif // _RGB_LED_H
