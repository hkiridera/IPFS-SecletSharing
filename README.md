# 依存パッケージ
python-pip  
python-dev  

# インストール
- git clone
```
git clone https://github.com/hkiridera/IPFS-SecletSharing.git
cd IPFS-SecletSharing
```
- pipの依存パッケージインストール
```
pip install -r requirements.txt
```
- IPFSのインストール  
raspberrypiにipfsをインストールするansible
```
git clone https://github.com/hkiridera/ansible.git
cd ansible
ansible-playbook -i inventory/hosts rpi-ipfs.yml
```


# 起動
- IPFS
```
ipfs init (初回のみ)
ipfs daemon
```
- IPFS-SecletSharing
```
python api.py
```

# API Server
```
http://localhost:8000/upload
http://localhost:8000/download
```
# GUI
```
http://localhost/IPFS-SecletSharing/html/upload.html
http://localhost/IPFS-SecletSharing/html/download.html
```