#include <avr/io.h>
#include <avr/interrupt.h>

ISR(TIMER1_COMPA_vect) {
  PINB |= _BV(PB5); // Toggle PB5
}

// Set up Timer1 to toggle the LED pin as fast as possible
void initTimer1() {
  // Use CTC (Clear Timer on Compare match) mode 
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1  = 0;
  OCR1A  = 1;
  TCCR1B |= (1 << WGM12) | (1 << CS10);
  TIMSK1 |= (1 << OCIE1A);
}

// 275kHz, perdiod=3.64us, pw+=1.82us, pw-=1.82us

int main() {
  DDRB |= _BV(PB5); // output direction on PB5 pin (D13)
  initTimer1();
  sei(); // Enable global interrupts.
  while(1);
  return 0;
}
