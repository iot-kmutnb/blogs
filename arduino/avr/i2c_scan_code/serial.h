#ifndef SERIAL_H
#define SERIAL_H

#include <avr/io.h>
#include <stdio.h>       // for printf()
#include <util/delay.h>  // for _delay_ms()

// Function prototypes
void init_uart(uint32_t);
int uart_putchar(char, FILE *);

#endif
