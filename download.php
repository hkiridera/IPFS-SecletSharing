
<?php
// file_get_contentsでデータを取得
$url = 'http://localhost:8000/download';
// 送信するデータ
$filename = 'metadata/4fd9b79bc51e4d77ba89b015c22a8fc7.metadata';
$file = file_get_contents('metadata/4fd9b79bc51e4d77ba89b015c22a8fc7.metadata');
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
