
<?php
// file_get_contentsでデータを取得
$url = 'http://192.168.12.11:8000/upload';
// 送信するデータ
$filename = 'sample.txt';
$image = file_get_contents('cc2.jpg');
// POSTするデータを作成
$header = [
    "Content-Type: application/json; charset=UTF-8;",
    "Content-Length: ".strlen($image),
];
$context = stream_context_create([
    'http' => [
        'method'=> 'POST',
        'header'=> implode("\r\n", $header),
        'content' => $image
    ]
]);
$raw_data = file_get_contents($url, false, $context);
// jsonからstdClassに変換
$data = json_decode($raw_data);
// 結果を表示
echo $data->message . PHP_EOL;
?>