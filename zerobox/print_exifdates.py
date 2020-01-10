import exifread
import os
import datetime

INPUT_DIR           = "RAW"
EXIF_DATE_FORMAT    = '%Y:%m:%d %H:%M:%S'

images = []

for root, dirs, files in os.walk(INPUT_DIR):
    for f in files:
        if f.lower().endswith(".arw"):
            images.append((root, f))

images = sorted(images, key=lambda item: item[1])

for image in images:

    full_name = os.path.join(*image)

    with open(full_name, "rb") as image_file:
        metadata = exifread.process_file(image_file)

        time = datetime.datetime.strptime(metadata["EXIF DateTimeOriginal"].values, EXIF_DATE_FORMAT)

        print("{:30s} : {}".format(image[1], time))