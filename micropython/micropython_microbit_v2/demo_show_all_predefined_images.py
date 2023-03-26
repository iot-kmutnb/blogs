####################################################
# MicroPython code for BBC Micro:bit v2
# - This code shows all predefined images of 
#   the Image class.
# - Press the button A to show images in sequence
#   in auto-running mode.
####################################################

from microbit import *

# Create a list of predefined images in the Image class.
all_images = [
    Image.HEART, Image.HEART_SMALL, Image.HAPPY,
    Image.SMILE, Image.SAD, Image.CONFUSED, 
    Image.ANGRY, Image.ASLEEP, Image.SURPRISED, 
    Image.SILLY, Image.FABULOUS, Image.MEH, 
    Image.YES, Image.NO, Image.TRIANGLE, 
    Image.TRIANGLE_LEFT, Image.CHESSBOARD, 
    Image.DIAMOND, Image.DIAMOND_SMALL, 
    Image.SQUARE, Image.SQUARE_SMALL, 
    Image.RABBIT, Image.COW, Image.MUSIC_CROTCHET, 
    Image.MUSIC_QUAVER, Image.MUSIC_QUAVERS, 
    Image.PITCHFORK, Image.XMAS, Image.PACMAN,
    Image.TARGET, Image.TSHIRT, Image.ROLLERSKATE,
    Image.DUCK, Image.HOUSE, Image.TORTOISE, 
    Image.BUTTERFLY, Image.STICKFIGURE, Image.GHOST,
    Image.SWORD, Image.GIRAFFE, Image.SKULL, 
    Image.UMBRELLA, Image.SNAKE, Image.SCISSORS ]

all_images.extend( Image.ALL_CLOCKS )
all_images.extend( Image.ALL_ARROWS )

sleep(10)
# Get the total number of images.
n = len(all_images)
print( 'There are %d images in total.' % n )

running = False # Set auto-running mode to false. 
index = 0       # Reset the image index.
while True:
    if button_a.was_pressed():
        running = not running
    if running or button_b.is_pressed():
        display.show( all_images[index] )
        index = (index+1) % n
        sleep(500)
####################################################
