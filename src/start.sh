#!/bin/bash

#service nginx start

## TOR start
sudo service tor

## IPFS起動
ipfs init
sed -i -e "s/127.0.0.1/0.0.0.0/g" ~/.ipfs/config
ipfs daemon &

sleep 30
## IPFS APIサーバ起動
mkdir -p tmp tmp2 metadata  
python api.py


## geth
geth init --datadir /tmp/eth_private genesis.json
geth --rpc --rpcport 8545 --rpcapi "web3,eth,net,personal" --rpccorsdomain "*" --rpcaddr "0.0.0.0" --datadir "/tmp/eth_private" --nodiscover --networkid 10 console

## wallet
ethereumwallet --rpc /tmp/eth_private/geth.ipc
