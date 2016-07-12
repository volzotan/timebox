SOURCE="/home/pi/timebox/box/JPEGS/*"
SERVER="grinzold:/var/www/timebox/jpegs/"

SOURCE_TEST="/home/pi/timebox/box/TEST/*"
SERVER_TEST="grinzold:/var/www/timebox/test/"

if [ "$1" = "sleep" ] 
then
    echo "sleep 60s"
    sleep 60
fi 

if [ "$1" = "test" ] 
then
    rsync -arv $SOURCE_TEST $SERVER_TEST
else
    rsync -arv $SOURCE $SERVER
fi 