import rpyc

import time
import multiprocessing

c = rpyc.connect("localhost", 18861)
# print(c.root.detect())
# print(c.root.get_status())
# print(c.root.connect())
# print(c.root.get_status())
# print(c.root.connect())
# print(c.root.disconnect_cameras())
# print(c.root.get_status())

print(c.root.detect_cameras())
cameras = c.root.get_cameras()
for cam in cameras:
    c.root.connect(cam)
prev_trigger_results = c.root.check_trigger_result()
print("prev: " + str(prev_trigger_results))
c.root.trigger()
print("timer: " + str(c.root.capture_timer))
for i in range(0, 15):
    print(c.root.check_trigger_result())
    time.sleep(0.25)

c.root.disconnect_all_cameras()