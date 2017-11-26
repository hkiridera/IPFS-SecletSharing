#!/bin/bash

service nginx start


## IPFS起動
/var/www/html/go-ipfs/ipfs init
sed -i -e "s/127.0.0.1/0.0.0.0/g" ~/.ipfs/config
/var/www/html/go-ipfs/ipfs daemon &

sleep 30
## IPFS APIサーバ起動
python /var/www/html/api.py
