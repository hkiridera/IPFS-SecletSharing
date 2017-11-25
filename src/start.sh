#!/bin/bash

service nginx start


## IPFS起動
/var/www/html/go-ipfs/ipfs init
/var/www/html/go-ipfs/ipfs daemon &

sleep 30
## IPFS APIサーバ起動
python /var/www/html/api.py
