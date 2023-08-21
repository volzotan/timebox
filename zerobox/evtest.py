import os
import math
import exifread
import cv2

INPUT_DIR = "/Users/volzotan/Downloads/test/captures"

DEFAULT_APERTURE = 8.0

images = []
for root, dirs, files in os.walk(INPUT_DIR):
    for f in files:
        if f.lower().endswith(".jpg"):

            if f.lower().endswith("_2.jpg"):
                continue

            images.append((root, f))

    break # non-recusive walk, please


images = sorted(images, key=lambda item: item[1])

# images = images[1150:1150+400]

# print(images)

# for image in images:
for i in range(0, len(images)):

    # if i % 2 == 1:
    #     continue

    # if i % 2 == 0:
    #     continue

    # import shutil

    # image = images[i]
    # actual_number = i
    # new_file = "cap_" + str(int(actual_number)) +".jpg"
    # new_path = os.path.join(INPUT_DIR, new_file)

    # print("{} --> {}".format(image[1], new_path)) 

    # shutil.move(os.path.join(*image), new_path)

    # continue

    image = images[i]
    full_name = os.path.join(image[0], image[1])

    try:

        with open(full_name, "rb") as image_file:
            metadata = exifread.process_file(image_file)

            # shutter speed in seconds (e.g. 0.5)

            shutter_speed_val = metadata["EXIF ExposureTime"].values[0]
            if shutter_speed_val.num == 0 or shutter_speed_val.den == 0:
                shutter_speed = 0
            else:
                shutter_speed = float(shutter_speed_val.num) / float(shutter_speed_val.den)

            # ISO (e.g. 100)

            iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

            # Aperture (e.g. 5.6)

            aperture_val = metadata["EXIF FNumber"].values[0]

            if aperture_val.num == 0 or aperture_val.den == 0:
                aperture = 0
            else:
                aperture = aperture_val.num / aperture_val.den

            if aperture <= 0:
                # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
                aperture = DEFAULT_APERTURE

            ev = math.log(aperture / shutter_speed, 2) - math.log(iso/100, 2)

            # print("brightness:: shutter: {:10} | aperture: {:3} | iso: {:4.0f} | EV: {:5.3f}".format(shutter_speed, aperture, iso, ev))
            # print("{} | ev: {:2.3f}".format(image[1], ev))
            
            # img = cv2.imread(full_name, cv2.IMREAD_ANYCOLOR)
            # gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

            # just load/convert the image to grayscale, opencv will already use the YUV model
            # and apply YUV color channel coefficients, so no additional luminance calculation
            # necessary

            img = cv2.imread(full_name, cv2.IMREAD_GRAYSCALE)

            # crop

            h, w = img.shape
            cropsize = 800
            img_cropped = img[int(h/2-cropsize/2):int(h/2+cropsize/2), int(w/2-cropsize/2):int(w/2+cropsize/2)]

            mean = img_cropped.mean()

            # print("mean: {:6.3f} | {:5.2f}%".format(mean, mean/2.56))

            ev_opt = ev + math.log(mean, 2) - math.log(128)
            print("ev measured: {:5.2f} | ev correct: {:5.2f} | diff: {:5.2f}".format(ev, ev_opt, ev-ev_opt))

            # cv2.imwrite(os.path.join(INPUT_DIR, "output.jpg"), img_cropped)
            # exit()


    except Exception as e:
        print("{} | error: {}".format(image[1], e))