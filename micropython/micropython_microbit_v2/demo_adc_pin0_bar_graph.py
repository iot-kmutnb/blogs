####################################################
# MicroPython code for BBC Micro:bit v2
# - This code reads an analog value from Pin0
#   every 250 msec and uses it to show a vertical line 
#   (bargraph).
####################################################

from microbit import *

# Create an image (all pixels are OFF). 
bar = Image(5,5)

while True:
    # Shift the image to the right by one position.
    bar = bar.shift_right(1)
    # Read an analog value from Pin0.
    value = pin0.read_analog()
    # Scale the analog value from 0..1023 to 0..5. 
    bar_height = scale(value,(0,1023),(0,5))
    print( 'Pin0: %d' % value )
    print( 'Bar height = %d' % bar_height )
    # Draw a vertical line (bar) according to the height.
    for y in range(5):
        if (y < bar_height):
            bar.set_pixel(0,4-y,9)
    # Show the bargraph if the button A is not pressed.
    if not button_a.is_pressed():
        display.show(bar)
    else:
        display.clear()
    sleep(250)
####################################################
