//pragma solidity ^0.4.23;
pragma solidity ^0.4.20;

contract ContentsBase{
    struct Contents {
        string      contentsName;           //ファイル名
        string      contentsDetails;        //詳細
        string      contentsURL;            //URL           購入者のみ
        uint        contentsPrice;          //価格(wei)
        string      contentsMetadata;       //メタデータ    購入者のみ
        mapping (address => bool) contentsPurchaser;    // 購入者リスト
    }
}