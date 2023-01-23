#ifndef I2C_H
#define I2C_H

#include <avr/io.h>
#include <util/delay.h>  // for _delay_ms()
#include <util/twi.h>    // for macros/constants for TWI

void    init_i2c(uint32_t speed);
uint8_t i2c_start_transmission(uint8_t);
void    i2c_end_transmission(void);
uint8_t i2c_write(uint8_t);
uint8_t i2c_read(uint8_t *, uint8_t);
uint8_t i2c_read_reg(uint8_t addr, uint8_t reg_addr);

#endif