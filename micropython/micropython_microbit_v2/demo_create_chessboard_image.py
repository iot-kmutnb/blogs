####################################################
# MicroPython code for BBC Micro:bit v2
# - This code creates an shows a user-defined 
#   chessboard image on the LED matrix display.
####################################################

from microbit import *

# Create an Image object for user-defined chessboard.
chessboard = Image()

# Get number of rows (m) and columns (n).
# Note that m = n = 5 pixels.
m = chessboard.height() 
n = chessboard.width()   
for x in range(n):
    for y in range(m):
        brightness = 9*((y%2 + 1 + x)%2)
        chessboard.set_pixel(x,y, brightness )

while True:
    # Show the builtin chessboard image
    display.show(Image.CHESSBOARD)
    sleep(1000)
    # Show the user-defined chessboard image
    display.show(chessboard)
    sleep(1000)

####################################################
