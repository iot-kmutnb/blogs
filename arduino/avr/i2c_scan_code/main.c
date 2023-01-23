#include <avr/io.h>
#include <stdio.h>       // for printf()
#include <util/delay.h>  // for _delay_ms()
#include "serial.h" 
#include "i2c.h" 

void scan_i2c_devices(void) {
  char sbuf[32];
  int n_devices = 0;
  printf("   ");
  for (uint8_t col = 0; col < 16; col++) {
    printf("%3x", col);
  }
  printf("\n");
  uint8_t addr = 0;
  for (uint8_t row = 0; row < 8; row++) {
    printf("%02x:", row << 4);
    for (uint8_t col = 0; col < 16; col++) {
      if (row == 0 && addr <= 1) {
        printf("   ");
      } else {
        uint8_t result = i2c_start_transmission(addr << 1);
        i2c_end_transmission();
        if (result) { // error
          printf(" --");
        } else {
          n_devices++;
          printf(" %2x", addr);
        }
      }
      addr++;
    }
    printf("\n");
  }
  printf("Devices found: %d\n", n_devices );
  printf("-------------------------------\n\n");
}

int main(void) {
  // Initialize I2C
  init_i2c(400000);
  // Initialize the UART and set baudrate to 115200.
  init_uart(115200);
  while (1) {
    printf("I2C Scan....\n");
    scan_i2c_devices();
    _delay_ms(4000);
  }
  return 0;
}

