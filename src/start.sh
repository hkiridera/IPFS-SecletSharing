#!/bin/bash

#service nginx start

## TOR start
#sudo service tor

## IPFS起動
ipfs init
sed -i -e "s/127.0.0.1/0.0.0.0/g" ~/.ipfs/config
ipfs daemon &

sleep 30
## APIサーバ起動
mkdir -p tmp tmp2 metadata  
python api.py


## geth
geth init --datadir ~/eth_private ./geth/genesis.json
geth --rpc --rpcport 8545 --rpcapi "web3,eth,net,personal" --rpccorsdomain "*" --rpcaddr "0.0.0.0" --datadir "~/eth_private" --nodiscover --networkid 10 

## wallet
#./ethereumwallet --rpc ~/ethprivate/geth.ipc
