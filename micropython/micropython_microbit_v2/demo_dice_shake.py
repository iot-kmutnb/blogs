####################################################
# MicroPython code for BBC Micro:bit v2
# - This code implements an electronic dice that
#   randomly selects a number between 1..6 
#   if the microbit board was shaken.
####################################################

from microbit import *
from random import randint

# Create a dictionary of Image objects for digits 1-6.
number_images = {
    1: '00000:00000:00900:00000:00000',
    2: '90000:00000:00000:00000:00009',
    3: '90000:00000:00900:00000:00009',
    4: '90009:00000:00000:00000:90009',
    5: '90009:00000:00900:00000:90009',
    6: '90009:00000:90009:00000:90009'
}

while True:
    # Check whether the Microbit board was shaked.
    if accelerometer.was_gesture('shake'): 
        # Get a random number between 1..6.
        number = randint(1, 6)
        # Show the current number
        print( 'Number: %d' % number )
        # Get the image for the current digit.
        display.show( Image(number_images[ number ]) )
    sleep(5)

####################################################
