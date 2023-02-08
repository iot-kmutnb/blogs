#include <avr/io.h>
#include <avr/interrupt.h>

ISR(TIMER1_COMPA_vect) {
  PINB |= _BV(PB1);
}

void initTimer1() {
  TCCR1A = 0;
  TCCR1B = 0;
  // Set timer1 in fast PWM mode:
  // f_CPU/2 = 16MHz/2 = 8MHz, 50% duty cycle
  ICR1  = 1;
  OCR1A = ICR1 >> 1; // 50% duty cycle
  TCCR1A |= (1 << WGM11) | (1 << COM1A1);
  TCCR1B |= (1 << WGM12) | (1 << WGM13) | (1 << CS10);
  // enable timer1 compare match interrupt
  TIMSK1 |= (1 << OCIE1A);
}

int main() {  
  DDRB |= (1 << PB1); // Set pin PB1 (D9 pin) as output
  initTimer1();
  sei(); // Enable global interrupts
  while(1);
  return 0;
}
