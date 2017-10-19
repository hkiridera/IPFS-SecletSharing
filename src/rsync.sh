while :
do
  rsync -avz metadata pi@${1}:/home/pi/IPFS-SecletSharing
  sleep 2
done
