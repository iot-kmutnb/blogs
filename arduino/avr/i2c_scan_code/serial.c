#include "serial.h"

#define CHECK_TIMEOUT  (10) // timeout in msec

int uart_putchar(char c, FILE *stream) {
  // Wait for empty transmit buffer
  uint8_t timeout = CHECK_TIMEOUT;
  while (!(UCSR0A & (1 << UDRE0))) {
    if (timeout == 0) {
      return 1;  // timeout occurred
    }
    timeout--;
    _delay_ms(1);
  }
  // Write the data byte into data-buffer register of the UART
  UDR0 = c;
  return 0;
}

// Initialize UART
void init_uart(uint32_t baud) {
  uint16_t value;
  DDRD &= ~(1 << DD0);  // set RXD (PD0) as input
  DDRD |= (1 << DD1);   // set TXD (PD1) as output
  if (baud >= 115200) {
    UCSR0A |= _BV(U2X0);
    value = F_CPU / 8 / baud - 1;
    UBRR0H = (uint8_t)(value >> 8);
    UBRR0L = (uint8_t)(value);
  } else {
    UCSR0A &= ~(_BV(U2X0));
    value = F_CPU / 16 / baud - 1;
    UBRR0H = (uint8_t)(value >> 8);
    UBRR0L = (uint8_t)(value);
  }
  // Enable both Tx and Rx of USART
  UCSR0B = (1 << RXEN0) | (1 << TXEN0);
  // Enable RX interrupt
  UCSR0B |= (1 << RXCIE0);
  // Set frame format: 8 data bits, 1 stop bit
  UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
  // Redirect stdout to UART
  fdevopen(&uart_putchar, NULL);
}
