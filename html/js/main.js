function uploadFileToServer(formData,status)
{
    var filename = status.filename[0].textContent
    //var bytesArray = new Uint8Array(formData);

    //var uploadURL ="http://192.168.12.118:8000/upload"; //Upload URL
    var uploadURL ="http://192.168.12.110:8000/upload"; //Upload URL
    var extraData ={}; //Extra Data.
    var jqXHR=$.ajax({
        xhr: function() {
        var xhrobj = $.ajaxSettings.xhr();
        if (xhrobj.upload) {
            xhrobj.upload.addEventListener('progress', function(event) {
                var percent = 0;
                var position = event.loaded || event.position;
                var total = event.total;
                if (event.lengthComputable) {
                    percent = Math.ceil(position / total * 100);
                }
                //Set progress
                status.setProgress(percent);
            }, false);
        }
        return xhrobj;
        },
        url: uploadURL,
        crossDomain: true,
        type: "POST",
        headers: {
            'File-Name': filename
        },
        contentType:'application/octet-stream',
        processData: false,
        cache: false,
        data: formData,
        dataType: false,
        success: function(data){
            status.setProgress(100);
            // metadataファイルのダウンロード
            let downloadData = new Blob([JSON.stringify(data)]);
            let downloadUrl  = (window.URL || window.webkitURL).createObjectURL(downloadData);
            let link = document.createElement('a');
            link.href = downloadUrl;
            link.download = filename + ".metadata";
            link.click();
            (window.URL || window.webkitURL).revokeObjectURL(downloadUrl);
            //$("#status1").append(JSON.stringify(data));        
        }
    });
  
    status.setAbort(jqXHR);
}


function downloadFileToServer(formData,status)
{
    var filename = status.filename[0].textContent.replace(/.metadata/g, "");
    //var bytesArray = new Uint8Array(formData);
    //filename = (new Function("return " + formData))();
    //filename = filename.filename;

    var uploadURL ="http://192.168.12.110:8000/download"; //Upload URL
    //var uploadURL ="http://localhost:8000/download"; //Upload URL
    var extraData ={}; //Extra Data.
    var jqXHR=$.ajax({
        xhr: function() {
        var xhrobj = $.ajaxSettings.xhr();
        if (xhrobj.upload) {
            xhrobj.upload.addEventListener('progress', function(event) {
                var percent = 0;
                var position = event.loaded || event.position;
                var total = event.total;
                if (event.lengthComputable) {
                    percent = Math.ceil(position / total * 100);
                }
                //Set progress
                status.setProgress(percent);
            }, false);
        }
        return xhrobj;
        },
        url: uploadURL,
        crossDomain: true,
        type: "POST",
        headers: {
            'File-Name': filename
        },
        contentType:'application/octet-stream',
        processData: false,
        cache: false,
        data: formData,
        dataType: false,
        success: function(data){
            status.setProgress(100);
            // オリジナルファイルのダウンロード
            // base64のデコード
            base = data.split(",")
            let downloadData = new Blob([toBlob(base[1])]);

            //ファイルダウンロード
            let downloadUrl  = (window.URL || window.webkitURL).createObjectURL(downloadData);
            let link = document.createElement('a');
            link.href = downloadUrl;
            link.download = filename;
            link.click();
            (window.URL || window.webkitURL).revokeObjectURL(downloadUrl);
            //$("#status1").append(JSON.stringify(data));        
        }
    });
  
    status.setAbort(jqXHR);
}
  

var rowCount=0;
function createStatusbar(obj)
{
     rowCount++;
     var row="odd";
     if(rowCount %2 ==0) row ="even";
     this.statusbar = $("<div class='statusbar "+row+"'></div>");
     this.filename = $("<div class='filename'></div>").appendTo(this.statusbar);
     this.size = $("<div class='filesize'></div>").appendTo(this.statusbar);
     this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo(this.statusbar);
     this.abort = $("<div class='abort'>Abort</div>").appendTo(this.statusbar);
     obj.after(this.statusbar);
  
    this.setFileNameSize = function(name,size)
    {
        var sizeStr="";
        var sizeKB = size/1024;
        if(parseInt(sizeKB) > 1024)
        {
            var sizeMB = sizeKB/1024;
            sizeStr = sizeMB.toFixed(2)+" MB";
        }
        else
        {
            sizeStr = sizeKB.toFixed(2)+" KB";
        }
  
        this.filename.html(name);
        this.size.html(sizeStr);
    }
    this.setProgress = function(progress)
    {      
        var progressBarWidth =progress*this.progressBar.width()/ 100; 
        this.progressBar.find('div').animate({ width: progressBarWidth }, 10).html(progress + "% ");
        if(parseInt(progress) >= 100)
        {
            this.abort.hide();
        }
    }
    this.setAbort = function(jqxhr)
    {
        var sb = this.statusbar;
        this.abort.click(function()
        {
            jqxhr.abort();
            sb.hide();
        });
    }
}

function handleFileUpload(file,obj)
{
    var reader = new FileReader();
    reader.readAsDataURL(file);
    //今のところテキストのみうまくいく
    //reader.readAsText(file);
    //読込終了後の処理
    reader.onload = function(ev){
        //ファイルの中身を取得する
        let fd = reader.result;
    
        //var fd = new FormData();
        //fd.append('file', files[i]);

        var status = new createStatusbar(obj); //Using this we can set progress.
        status.setFileNameSize(file.name,file.size);
        uploadFileToServer(fd,status);
    }
}

function handleFileDownload(file,obj)
{
    
    var reader = new FileReader();
    //reader.readAsDataURL(file);
    reader.readAsText(file);
    //読込終了後の処理
    reader.onload = function(ev){
        //ファイルの中身を取得する
        let fd = reader.result;
    
        //var fd = new FormData();
        //fd.append('file', files[i]);

        var status = new createStatusbar(obj); //Using this we can set progress.
        status.setFileNameSize(file.name,file.size);
        downloadFileToServer(fd,status);
    }
}

//引数はbase64形式の文字列
function toBlob(base64) {
    var bin = atob(base64.replace(/^.*,/, ''));
    var buffer = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) {
        buffer[i] = bin.charCodeAt(i);
    }
    // Blobを作成
    try{
        var blob = new Blob([buffer.buffer], {
            type: 'image/png'
        });
    }catch (e){
        return false;
    }
    return blob;
}