
<?php
// file_get_contentsでデータを取得
$url = 'http://localhost:8000/upload';
// 送信するデータ
$filename = 'sample.txt';
$file = file_get_contents($filename);
// POSTするデータを作成
$header = [
    "Content-Type: application/json; charset=UTF-8;",
    "Content-Length: ".strlen($file),
    "File-Name: " . $filename
];
$context = stream_context_create([
    'http' => [
        'method'=> 'POST',
        'header'=> implode("\r\n", $header),
        'content' => $file
    ]
]);
$raw_data = file_get_contents($url, false, $context);
// 結果を表示
echo $raw_data;
?>
