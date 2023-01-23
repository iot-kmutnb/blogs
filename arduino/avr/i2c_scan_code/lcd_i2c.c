#include "lcd_i2c.h"
#include <util/delay.h>  // for _delay_us() and _delay_ms()

// Global Variable
uint8_t pcf8574_addr = PCF8574_ADDR;

#define  BIT_RS  (0x01) 
#define  BIT_RW  (0x02)
#define  BIT_CS  (0x04)
#define  BIT_BL  (0x08)  // Backlight

uint8_t i2c_pcf8574_write( uint8_t data ) {
  uint8_t result;
  result = i2c_start_transmission( (pcf8574_addr << 1) | TW_WRITE );
  if ( result ) {
    i2c_end_transmission();
    return 1;
  } 
  i2c_write(data);
  i2c_end_transmission();
  return 0; // ok
}

void i2c_write4bits( uint8_t data ) {
  data = data | BIT_BL;
  i2c_pcf8574_write( data | BIT_CS );
  _delay_us(200);
  i2c_pcf8574_write( data );
  _delay_us(200);
}

void lcd_init(uint8_t addr ) {
  pcf8574_addr = addr;
  // Reset the LCD module
  i2c_write4bits( 0x03 << 4 );
  _delay_ms(5);
  i2c_write4bits( 0x03 << 4 );
  _delay_ms(150);
  i2c_write4bits( 0x03 << 4 );
  i2c_write4bits( 0x02 << 4 );
  // Set LCD to 4-bit mode
  lcd_write_command(LCD_FUNCTION_SET | LCD_4BITMODE | LCD_2LINE | LCD_5x8DOTS);
  _delay_ms(5);
  // Display and cursor settings
  lcd_write_command(LCD_DISP_CTRL| LCD_DISP_ON);
  _delay_ms(5);
  lcd_write_command(LCD_ENTRY_MODE_SET | LCD_ENTRY_LEFT);
  _delay_ms(5);
  // clear display and return home
  lcd_write_command(LCD_CLEAR_DISP);
  _delay_ms(5);
  lcd_write_command(LCD_RETURN_HOME);
  _delay_ms(5);
}

void lcd_write_command(uint8_t value) {
  uint8_t hi_nibble = value & 0xf0;   
  uint8_t lo_nibble = (value << 4) & 0xf0;
  i2c_write4bits( hi_nibble );
  i2c_write4bits( lo_nibble );
}

void lcd_write_data(uint8_t value) {
  uint8_t hi_nibble = value & 0xf0;   
  uint8_t lo_nibble = (value << 4) & 0xf0;
  i2c_write4bits( hi_nibble | BIT_RS );
  i2c_write4bits( lo_nibble | BIT_RS );
}

void lcd_write_line(const char *str) {
  uint8_t cnt=0;
  for (int i=0; str[i] != 0 && cnt++ < 20; i++) {
    lcd_write_data(str[i]);
  }
}

void lcd_set_cursor(uint8_t x, uint8_t y) {
  uint8_t addr;
  addr = ((y == 0) ? 0x00 : 0x40) + x;
  lcd_write_command(LCD_SET_DDRAM_ADDR | addr);
}
