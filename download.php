
<?php
// file_get_contentsでデータを取得
$url = 'http://192.168.12.110:8000/download';
// 送信するデータ
$filename = 'metadata/0217ad03124e41fc9c8f6e7830bfd7fb.metadata';
$file = file_get_contents('metadata/0217ad03124e41fc9c8f6e7830bfd7fb.metadata');
// POSTするデータを作成
$header = [
    "Content-Type: application/json; charset=UTF-8;",
    "Content-Length: ".strlen($file),
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
