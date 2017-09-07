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
api = ipfsapi.connect('127.0.0.1', 5001)
#api = ipfsapi.connect('192.168.12.118', 5001)
#api = ipfsapi.connect('https://ipfs.io/ipfs/')

# 難読化
iv = "nanndokuka"

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
        encrypt_data = get_encrypt_data(body, password, iv)

        # 一旦ファイルを保存
        with open("upload/" + id.hex, 'wb') as f:
            f.write(encrypt_data)

        # ファイル分割
        ## 分割容量 1MB
        #size = 1024*1024
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
        msg = {
            'id': id.hex,                   ## filename
            'div_num': div_num,             ## 分割数
            #'encrypt_data': encrypt_data,   ## 暗号化したデータ(不要？)
            'password': password,           ## パスワード
            'ipfs': ipfs_hashs   ## 分割したファイルのIPFSアドレス一覧
        }

        # メタデータ保存
        c = open("metadata/" + id.hex + ".metadata", 'wb')
        c.write( json.dumps(msg) )
        c.close

        res.body = json.dumps(msg)



class metadata(object):
    # getされた時の動作
    def on_get(self, req, res, id):
        # metadatafileの参照
        try:
            f = open("metadata/" + id + ".metadata", 'rb')
            data = f.read()
            msg = data
            f.close()
        except IndexError:
            print 'Usage: %s TEXTFILE' % script_name
            msg = {"message": "File Not Found."}
        except IOError:
            print '"%s" cannot be opened.' % arg
            msg = {"message": "File Not Found."}
        

        res.body = json.dumps(msg)

class download(object):
    # getされた時の動作
    def on_get(self, req, res):
        msg = {
            "message": "Welcome to the Falcon"
        }
        res.body = json.dumps(msg)

    # postされた時の動作
    def on_post(self, req, res):
        ## id.metadataのファイルを受け取る
        # bodyからファイルのバイナリ取得
        body = req.stream.read()
        json_dict = json.loads(body)
        
        ## jsonの構文解析をする
        ### jsonからidを取得
        id = json_dict["id"]
        password = json_dict["password"]
        div_num = json_dict["div_num"]

        ## divnumの数だけループする
        ## ipfsのハッシュ分だけfileをdownloadする
        b = open("download/" + id + ".seclet", 'wb')
        for i in range(div_num):
            ## 結合する
            b.write( api.cat(json_dict["ipfs"][i]) )
        b.close()

        ## 復号化前のデータを取得
        b = open("download/" + id + ".seclet", 'rb')
        encrypt_data = b.read()
        b.close()

        ## 復号化
        decrypt_data = get_decrypt_data(encrypt_data, password, iv)
        
        ## ファイル出力
        out = open("download/" + id , 'wb')
        out.write(decrypt_data)

        ## return
        msg = {
            "message": "Succese"
        }
        
        ## Fileを返す(返せないのでdownloadに保存)
        res.body = json.dumps(msg)


## Routing
app = falcon.API()
app.add_route("/upload", upload())
app.add_route("/metadata/{id}", metadata())
app.add_route("/download/", download())





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
