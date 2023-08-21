from datetime import datetime, timedelta


start = datetime.now()
from PIL import Image
print("pil: {:.3f}s".format((datetime.now()-start).total_seconds()))

start = datetime.now()
import numpy as np
np.zeros(1)
print("numpy: {:.3f}s".format((datetime.now()-start).total_seconds()))

start = datetime.now()
import cv2
print("cv2: {:.3f}s".format((datetime.now()-start).total_seconds()))
