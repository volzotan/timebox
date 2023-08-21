#!/bin/sh

DIR="/Users/volzotan/Downloads/test/test4"

NEWEST_FILE=$(ls $DIR | tail -1)

if ![ $? ]
    echo "non zero return value"
fi

echo $NEWEST_FILE

exit 0

raspistill -o test.jpg -t 1000

raspistill --settings -t 0

raspistill                          \
    -o test2.jpg                    \
    -t 1000                         \
    --exposure off                  \
    --shutter 16                    \
    --ISO 50                        