import sys
import time
from pymouse import PyMouse

mouse = PyMouse()

x, y, b = int(sys.argv[1]) + 20, int(sys.argv[2]) + 20, int(sys.argv[3])

if b == 3:
	scroll_amount = int(sys.argv[4]) if len(sys.argv) > 4 else 5
	mouse.scroll(x, y, scroll_amount)
elif b == 4:
	scroll_amount = int(sys.argv[4]) if len(sys.argv) > 4 else 5
	mouse.scroll(x, y, -scroll_amount)
else:
	mouse.press(x, y, b)
	time.sleep(0.1)
	mouse.release(x, y, b)