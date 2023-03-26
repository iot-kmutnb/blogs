####################################################
# MicroPython code for BBC Micro:bit v2
# - This code draws a lower triangular matrix and
#   an upper triangular matrix on the 5x5 LED display.
####################################################

from microbit import *
from music import play, POWER_UP
import time

def draw_triangular_matrix(is_lower=True):
    for x in range(5):
        for y in range(5):
            if is_lower:
                value = 9*(x<=y)
            else:
                value = 9*(x>=y)
            display.set_pixel(x,y,value)

# Play sound
play(POWER_UP)

while True:
    # Show a lower triangular matrix
    draw_triangular_matrix()
    time.sleep(1.0)
    # Show a upper triangular matrix
    draw_triangular_matrix(False)
    time.sleep(1.0)

####################################################
