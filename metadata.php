<?php
// file_get_contentsでデータを取得
$url = 'http://localhost:8000/metadata/0217ad03124e41fc9c8f6e7830bfd7fba';
// 送信するデータ
// POSTするデータを作成
$header = [
    "Content-Type: application/json; charset=UTF-8;",
];
$context = stream_context_create([
    'http' => [
        'method'=> 'GET',
        'header'=> implode("\r\n", $header),
    ]
]);
$raw_data = file_get_contents($url, false, $context);
// 結果を表示
echo $raw_data;
?>