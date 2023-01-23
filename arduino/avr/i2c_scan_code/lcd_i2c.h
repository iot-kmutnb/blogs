#ifndef LCD_I2C_H
#define LCD_I2C_H

#include <avr/io.h>
#include <util/delay.h>
#include "i2c.h"

extern uint8_t pcf8574_addr;

#define PCF8574_ADDR        (0x27)
#define PCF8574A_ADDR       (0x3F)

// LCD commands
#define LCD_CLEAR_DISP      (0x01)
#define LCD_RETURN_HOME     (0x02)
#define LCD_ENTRY_MODE_SET  (0x04)
#define LCD_DISP_CTRL       (0x08)
#define LCD_CURSOR_SHIFT    (0x10)
#define LCD_FUNCTION_SET    (0x20)
#define LCD_SET_CGRAM_ADDR  (0x40)
#define LCD_SET_DDRAM_ADDR  (0x80)

// Flags for display entry mode
#define LCD_ENTRY_RIGHT     (0x00)
#define LCD_ENTRY_LEFT      (0x02)
// Flags for display on/off control
#define LCD_DISP_ON         (0x04)
#define LCD_CURSOR_ON       (0x02)
#define LCD_BLINK_ON        (0x01)
// Flags for display/cursor shift
#define LCD_DISP_MOVE       (0x08)
#define LCD_CURSOR_MOVE     (0x00)
#define LCD_MOVE_RIGHT      (0x04)
#define LCD_MOVE_LEFT       (0x00)
// Flags for function set
#define LCD_4BITMODE       (0x00)
#define LCD_2LINE          (0x08)
#define LCD_5x8DOTS        (0x00)

void lcd_init(uint8_t addr);
void lcd_write_line(const char *);
void lcd_set_cursor(uint8_t, uint8_t);
void lcd_write_command(uint8_t);
void lcd_write_data(uint8_t);

#endif

