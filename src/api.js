/* 1. expressモジュールをロードし、インスタンス化してappに代入。*/
var express = require("express");
var app = express();
var fs = require("fs");
var bodyParser = require('body-parser');
var multer = require("multer");
var crypto = require('crypto');

var ipfsAPI = require('ipfs-api')
var ipfs = ipfsAPI('localhost', '5001', {
    protocol: 'http'
})

// 暫定的にファイルを保存する
var algorithm = 'aes-256-ctr';
var passphrase = "7IeZlmfz";

// CORSを許可する
app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, File-Name");
    next();
});
app.use(bodyParser.urlencoded({
    extended: false
}));
app.use(multer({
    dest: './tmp2/'
}).single('file'));

app.post('/upload', function (req, res) {

    fs.readFile(req.file.path, function (err, data) {
        // ファイル名
        const filename = req.file.originalname;
        // ファイルの内容からidとなるハッシュ値を取得する
        const md5hash = crypto.createHash('md5');
        md5hash.update(data, 'binary');
        const id = md5hash.digest('hex');
        let filepath = __dirname + "/tmp/" + id;
        //暗号化
        encrypt_data = encrypt(data);


        //暗号化したデータの書き込み
        fs.writeFile(filepath, encrypt_data, function (err) {
            //失敗ならエラーを返す
            if (err) {
                console.log(err);
            }

            const splitLength = 500 * 1024 ;
            let arr = splitByLength(encrypt_data, splitLength);
            const div_num = arr.length
            let ipfs_hashs = []
            // 暗号化後のデータを指定の容量で分割する
            for (let i = 0; i < div_num; i++) {
                console.log("分割数 : " + arr.length);

                // 分割後のファイルを保存する
                let filepath_frac = __dirname + "/tmp/" + id + ".frac" + i;
                fs.writeFile(filepath_frac, arr[i], function (err) {
                    // 失敗ならエラーを返す
                    if (err) {
                        console.log(err);
                    }
                    // ipfsへアップロード
                    ipfs.util.addFromFs(filepath_frac, {
                        recursive: true,
                        ignore: ['subfolder/to/ignore/**']
                    }, (err, result) => {
                        if (err) {
                            throw err
                        }
                        // ipfsの結果を追加
                        ipfs_hashs.push(result)
                        console.log(result[0].hash)
                    })

                });

            }
            setTimeout(function () {
                // メタデータファイルを保存する
                let filepath_metadata = __dirname + "/metadata/" + filename + ".metadata";
                console.log(filepath_metadata)
                msg = {
                    'id': id, // id
                    'filename': filename, // filename
                    'div_num': div_num, // 分割数
                    //'encrypt_data': encrypt_data,   // 暗号化したデータ(不要？)
                    //'password': password,           // パスワード
                    //'iv': iv,               // 初期化ベクトル
                    'ipfs': ipfs_hashs // 分割したファイルのIPFSアドレス一覧
                }
                fs.writeFile(filepath_metadata, JSON.stringify(msg), function (err) {
                    // 失敗ならエラーを返す
                    if (err) {
                        console.log(err);
                    }
                    console.dir(msg, {
                        depth: null
                    });
                    res.end(JSON.stringify(msg));
                });
            }, 6000);
        });
    });


});

app.post('/download', function (req, res) {

    fs.readFile(req.file.path, function (err, data) {
        // ファイル名
        //const filename = req.file.originalname;
        const metadata = JSON.parse(data)
        console.dir(metadata, {
            depth: null
        });

        //復号化
        //console.log(decrypt(data));
        const div_num = metadata.div_num;
        let ipfs_hashs = metadata.ipfs;
        const id = metadata.id;
        const filename = metadata.filename;
        
        for (let i = 0; i < div_num; i++) {
            // ipfsからダウンロード
            //ipfs.files.cat(ipfs_hashs[i].Hash, {
            ipfs.files.get(ipfs_hashs[i][0].hash, function (err, stream) {
                stream.on('data', (file) => {
                    // write the file's path and contents to standard out
                    //console.log(file.path)
                    //console.dir(id)
                    let filepath_metadata = __dirname + "/tmp/" + ipfs_hashs[i][0].path;
                    file.content.pipe(fs.createWriteStream(filepath_metadata))


                })
            })
        }


        // 復号化
        const filepath_frac = __dirname + "/tmp/" + id + ".frac";
        let frac_data = [];
        setTimeout(function () {
        
        for (let i = 0; i < div_num; i++) {
            fs.readFile(filepath_frac + i, function (err, data) {
                frac_data[ipfs_hashs[i][0].path] = data;
                console.log(frac_data[ipfs_hashs[i][0].path])
            })
        }
        }, 60000);

        let encrypt_data = "";
        setTimeout(function () {
            for (let i = 0; i < div_num; i++) {
                
                //encrypt_data = Buffer.concat(encrypt_data + frac_data[metadata.id + ".frac" + i]);
                encrypt_data += frac_data[metadata.id + ".frac" + i]
            }
        }, 90000);

        setTimeout(function () {
            //復号化
            //console.log(encrypt_data)
            //console.log(decrypt(encrypt_data));
            const filepath_decrypt = __dirname + "/download/" + filename;
            console.log(filepath_decrypt)
            decrypt_data = decrypt(encrypt_data)
            fs.writeFile(filepath_decrypt, decrypt_data, function (err) {
                console.log("success!!")
            })
        }, 120000);

    });


});

var server = app.listen(3000, function () {
    var host = server.address().address;
    var port = server.address().port;
    console.log("listening at http://%s:%s", host, port);
});

function splitByLength(str, length) {
    var resultArr = [];
    if (!str || !length || length < 1) {
        return resultArr;
    }
    var index = 0;
    var start = index;
    var end = start + length;
    while (start < str.length) {
        resultArr[index] = str.slice(start, end);
        index++;
        start = end;
        end = start + length;
    }
    return resultArr;
}


var encrypt = (text) => {
    var cipher = crypto.createCipher(algorithm, passphrase)
    var crypted = cipher.update(text, 'utf8', 'base64')
    crypted += cipher.final('base64');
    return crypted;
}

var decrypt = (text) => {
    var decipher = crypto.createDecipher(algorithm, passphrase)
    var dec = decipher.update(text, 'base64', 'utf8')
    dec += decipher.final('utf8');
    return dec;
}