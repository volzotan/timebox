BOX="/home/pi/timebox"

sudo python $BOX/box/box.py test 

echo "sleep 10 seconds"
sleep 10

sh $BOX/copy_to_server.sh test