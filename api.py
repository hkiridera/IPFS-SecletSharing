# coding:utf-8
import falcon
import json
import uuid
import sys
import os.path

from Crypto.Cipher import AES
import hashlib
import base64

## IPFS Setting
import ipfsapi
#api = ipfsapi.connect('127.0.0.1', 5001)
api = ipfsapi.connect('192.168.12.118', 5001)
#api = ipfsapi.connect('https://ipfs.io/ipfs/')


class upload(object):
    
    # getされた時の動作
    def on_get(self, req, res):
        msg = {
            "message": "Welcome to the Falcon"
        }
        res.body = json.dumps(msg)

    # postされた時の動作
    def on_post(self, req, res):
        
        # ファイル名をUUIDとする。
        id = uuid.uuid4() 
        
        # bodyからファイルのバイナリ取得
        body = req.stream.read()
        
        # 暗号化
        password = "password"
        iv = "nanndokuka"
        encrypt_data = get_encrypt_data(body, password, iv)

        # 一旦ファイルを保存
        with open("upload/" + id.hex, 'wb') as f:
            f.write(encrypt_data)

        # ファイル分割
        ## 分割容量 1MB
#        size = 1024*1024
        ## 分割容量 1KB
        size = 1024
        l = os.path.getsize("upload/" + id.hex)
        ## 分割数
        div_num = (l + size - 1) / size
        last = (size * div_num) - l

        b = open("upload/" + id.hex, 'rb')
        ## ipfs_hashs
        ipfs_hashs = []
        for i in range(div_num):
            read_size = last if i == div_num-1 else size
            data = b.read(read_size)  ## data = 分割後のファイル内容
            out = open("upload/" + id.hex + '.frac' + str(i), 'wb')
            out.write(data)
            out.close()
            
            ## IFPSにアップロード
            ipfs_hashs.append( api.add("upload/" + id.hex + '.frac' + str(i)) ) 
        b.close()
        
        
        ##返り値&metadata生成
        resp = {
            'id': id.hex,                   ## filename
            'div_num': div_num,             ## 分割数
#            'encrypt_data': encrypt_data,   ## 暗号化したデータ(不要？)
            'password': password,           ## パスワード
            'ipfs': ipfs_hashs   ## 分割したファイルのIPFSアドレス一覧
        }

        # メタデータ保存
        c = open("metadata/" + id.hex + ".metadata", 'wb')
        c.write( json.dumps(resp) )

        ## return
        res.body = json.dumps(resp)


## Routing
app = falcon.API()
app.add_route("/upload", upload())






## 暗号化
def get_encrypt_data(raw_data, key, iv):
    raw_data_base64 = base64.b64encode(raw_data)
    # 16byte
    if len(raw_data_base64) % 16 != 0:
        raw_data_base64_16byte = raw_data_base64
        for i in range(16 - (len(raw_data_base64) % 16)):
            raw_data_base64_16byte += "_"
    else:
        raw_data_base64_16byte = raw_data_base64
    secret_key = hashlib.sha256(key).digest()
    iv = hashlib.md5(iv).digest()
    crypto = AES.new(secret_key, AES.MODE_CBC, iv)
    cipher_data = crypto.encrypt(raw_data_base64_16byte)
    cipher_data_base64 = base64.b64encode(cipher_data)
    return cipher_data_base64

## 復号化
def get_decrypt_data(cipher_data_base64, key, iv):
    cipher_data = base64.b64decode(cipher_data_base64)
    secret_key = hashlib.sha256(key).digest()
    iv = hashlib.md5(iv).digest()
    crypto = AES.new(secret_key, AES.MODE_CBC, iv)
    raw_data_base64_16byte = crypto.decrypt(cipher_data)
    raw_data_base64 = raw_data_base64_16byte.split("_")[0]
    raw_data = base64.b64decode(raw_data_base64)
    return raw_data


if __name__ == "__main__":
    from wsgiref import simple_server
    httpd = simple_server.make_server("0.0.0.0", 8000, app)
    httpd.serve_forever()
