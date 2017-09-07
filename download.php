
<?php
// file_get_contentsでデータを取得
$url = 'http://localhost:8000/download';
// 送信するデータ
$file = file_get_contents('metadata/1b89fba8602cb7ee34b90df361e1d9f9.metadata');
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
