####################################################
# MicroPython code for BBC Micro:bit v2
# - This code rotates the arrow on the LED matrix display.
# - If the button A was pressed, rotate the arrow anti-clockwise.
# - If the button B was pressed, rotate the arrow clockwise.
# - If the logo was touched, show the arrow pointing up.
####################################################

from microbit import *
from random import *

# Create a list of arrow images (predefined)
images = Image.ALL_ARROWS

# Get the number of arrow images
n = len(images)

# Reset the index value.
index = 0

while True:
    if pin_logo.is_touched():
        # Reset the index value to zero.
        index = 0
    elif button_a.was_pressed():
        # Decrement the index value (rotate anti-clockwise).
        index = (n+index-1) % n
    elif button_b.was_pressed():
        # Increment the index value (rotate clockwise).
        index = (n+index+1) % n
    # Show the arrow according to the index value.
    display.show( images[index] )

####################################################
