FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y vim nginx git python python-dev python-pip wget curl

WORKDIR /var/www/html/
COPY . .

## IPFS
RUN wget https://dist.ipfs.io/go-ipfs/v0.4.13/go-ipfs_v0.4.13_linux-amd64.tar.gz && \
    tar zxvf go-ipfs_v0.4.13_linux-amd64.tar.gz

RUN pip install -r requirements.txt

EXPOSE 80 5001 18000
CMD [ "bash", "start.sh" ]