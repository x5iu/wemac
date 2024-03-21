import sys
import time

from pymouse import PyMouse

mouse = PyMouse()

x, y, b = int(sys.argv[1]) + 20, int(sys.argv[2]) + 20, int(sys.argv[3])
mouse.press(x, y, b)
time.sleep(0.1)
mouse.release(x, y, b)


