pragma solidity ^0.4.10;

// todo
// Data用コントラクト
// ロジック用コントラクトから呼び出す想定

contract Data {
    address contractAdmin;      //コントラクトのオーナ
    address contractAddress;    //コントラクトのアドレス

    struct Item {
        address     dataOwner;      //登録者のアドレスを記録
        string      ipfsAddress;    //ipfsのアドレス
        
        string      name;           //ファイル名
        string      details;        //詳細
        string[]    tags;           //タグ 複数の場合はカンマ区切りで登録すること
        uint        registeredDate; //登録日時
        uint        dlCount;         //DL数
        string[]    comment;        //コメント 構造体にする？
        uint        price;          //価格
        string[]    extraData;      //その他データ

        //管理用
        bool    locked;             //編集可否フラグ
        bool    deleted;            //削除フラグ
    }

    Item[] item;

    // initialize
    function Data() public {
        contractAdmin = msg.sender;
        contractAddress = address(this);
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* データの中身を取得 */
    // index番号をを引数に、ipfsのアドレスを返す。
    function getItemAddress(uint index) public constant returns (string ) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].ipfsAddress;
        } else {
            return ;
        }
        
    }

    // index番号とタグ番号を引数に、タグを返す。
    function getItemTags(uint index, uint num) public constant returns (string ) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].tags[num];
        } else {
            return ;
        }
    }

    // index番号を引数に、詳細を返す
    function getItemDetails(uint index) public constant returns (string ) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].details;
        } else {
            return ;
        }
    }

    // index番号を引数に、item名を返す
    function getItemName(uint index) public constant returns (string ) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].name;
        } else {
            return ;
        }
    }
    //lock状態を確認する
    function getLock(uint index) public constant returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].locked;
        } else {
            return true;
        }
    }

    //データ所有者を確認する
    function getDataOwner(uint index) public constant returns (address) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].dataOwner;
        } else {
            return ;
        }
    }

    //削除の確認
    function getDeleted(uint index) public constant returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].deleted;
        } else {
            return true;
        }
    }

    //登録日時を返す
    function getregisteredDate(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].registeredDate;
        } else {
            return 0;
        }
    }

    //DL数を返す
    function getdlCount(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].dlCount;
        }else {
            return 0;
        }
    }

    // コメントを返す
    //i = index番号
    //j= コメント番号
    function getComment(uint index, uint num) public constant returns (string) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].comment[num];
        } else {
            return ;
        }
    }

    //価格を返す
    function getPrice(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].price;
        }else {
            return 0;
        }
    }


    //etraDataを返す
    function getEtraData(uint index, uint num) public constant returns (string) {
        //データの存在確認
        if (index > getIndex()) {
            return;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].extraData[num];
        }else {
            return;
        }
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* 検索 */

    //登録されているデータ数を返す
    function getIndex() public constant returns (uint) {
        return item.length;
    }

    //index番号のitemに付いているタグ総数を返す
    function getTagsIndex(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return 0;
        }
        return item[index].tags.length;
    }

    //index番号のitemに付いているコメント総数を返す
    function getCommentIndex(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return 0;
        }
        return item[index].comment.length;
    }

    //IPFSアドレスに一致したitemの存在確認
    function isIpfsAddress(string vAddress) public constant returns (bool) {
        // itemの数だけループする。
        for ( uint i = 0; i < item.length; i++ ) {
            //ipfsアドレスが登録済みであることを確認する。
            if (keccak256(item[i].ipfsAddress) == keccak256(vAddress) ) {
                // 一致した場合はtrueを返す
                return true;
            }
        }        
        //存在しない場合はfalseを返す。
        return false;
    }

    //index番号のitemに付いているextraDataの総数を返す
    function getExtraDataIndex(uint index) public constant returns (uint) {
        //データの存在確認
        if (index > getIndex()) {
            return 0;
        }
        return item[index].extraData.length;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* データ登録,更新 */

    // 新規データ登録
    // 登録したindex番号を返す
    function putItem(string vAddress, string vName, string vDetails, bool vLocked, uint vPrice) public returns (uint) {
        //登録済みの場合は何もしない。
        if ( isIpfsAddress(vAddress) ) {
            return ;
        }

        Item memory tmp;

        //引数から入力
        tmp.ipfsAddress = vAddress;
        tmp.name = vName;
        tmp.details = vDetails;
        tmp.price = vPrice;
        tmp.locked = vLocked;

        //自動入力項目
        tmp.dlCount = 0;
        tmp.dataOwner = msg.sender;
        tmp.deleted = false;
        tmp.registeredDate = now;
        


        item.push(tmp);
        //登録したindex番号を返す
        return getIndex();
    }

    // index番号のitemにコメントを付与する
    //成功時: true, 失敗時: false
    function putComments(uint index, string vComment) public returns(bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        if ( (item[index].deleted == false) && (item[index].locked == false) ) {
            //コメント欄の最後に追記する
            item[index].comment.push(vComment);
            //更新時間を更新する。
            item[index].registeredDate = now;
            //成功時にtrueを返す
            return true;
        }
        //失敗時にfalseを返す
        return false;
    }

    // index番号のitemにタグを付与する
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function putTags(uint index, string vTag) public returns(bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( (item[index].deleted == false) && (item[index].locked == false) && ( (item[index].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {

            //既に登録済みでないことを確認する
            for (uint i; i < getTagsIndex(index); i++) {
                if ( keccak256(item[index].tags[i]) == keccak256(vTag) ) {
                    //登録済みの場合はfalseを返す。
                    return false;
                } else {
                    continue;
                }
            }
            //登録済みでない場合はタグの最後に追記する
            item[index].tags.push(vTag);
            //更新時間を更新する。
            item[index].registeredDate = now;
            //成功時にtrueを返す
            return true;
        }
        //失敗時にfalseを返す
        return false;
    }

    //価格を登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function putPrice(uint index, uint vPrice) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( (item[index].deleted == false) && (item[index].locked == false) && ( (item[index].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {
            item[index].price = vPrice;
            //更新時間を更新する。
            item[index].registeredDate = now;
            return true;
        }
        return false;
    }

    //lockedを登録する。
    //管理者のみ実行可能
    //成功時: true, 失敗時: false
    function putLocked(uint index, bool vLocked) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //更新者が管理者であること
        if ( (item[index].deleted == false) && (msg.sender == contractAdmin) ) {
            item[index].locked = vLocked;
            //更新時間を更新する。
            item[index].registeredDate = now;
            return true;
        }
        return false;
    }

    //deletedを登録する。
    //管理者のみ実行可能
    //成功時: true, 失敗時: false
    function putDeleted(uint index, bool vDeleted) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //更新者が管理者であること
        if ( msg.sender == contractAdmin ) {
            item[index].deleted = vDeleted;
            //更新時間を更新する。
            item[index].registeredDate = now;
            return true;
        }
        return false;
    }

    //nameを登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function putName(uint index, string vName) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( (item[index].deleted == false) && (item[index].locked == false) && ( (item[index].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {
            item[index].name = vName;
            //更新時間を更新する。
            item[index].registeredDate = now;
            return true;
        }
        return false;
    }

    //detailsを登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function putDetails(uint index, string vDetails) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( (item[index].deleted == false) && (item[index].locked == false) && ( (item[index].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {
            item[index].details = vDetails;
            //更新時間を更新する。
            item[index].registeredDate = now;
            return true;
        }
        return false;
    }

    // index番号のitemにコメントを付与する
    //成功時: true, 失敗時: false
    function putExtraData(uint index, string vExData) public returns(bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        if ( (item[index].deleted == false) && (item[index].locked == false) ) {
            //コメント欄の最後に追記する
            item[index].extraData.push(vExData);
            //更新時間を更新する。
            item[index].registeredDate = now;
            //成功時にtrueを返す
            return true;
        }
        //失敗時にfalseを返す
        return false;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* データ削除 */

    //タグの削除
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function deleteTags(uint index, string vTag) public returns (bool) {
        //データの存在確認
        if (index > getIndex()) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( (item[index].deleted == false) && (item[index].locked == false) && ( (item[index].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {
            //タグを全部検索する
            for ( uint i = 0; i < getTagsIndex(index); i++ ) {
                //一致するタグを検索
                if ( keccak256(item[index].tags[i]) == keccak256(vTag) ) {
                    //最後のindexでないことを確認する。
                    if (i == getTagsIndex(index)) {
                        return false;
                    }
                    //タグ番号を1個前にずらす。                        
                    for ( uint j = i; j < getTagsIndex(index) - 1; j++ ) {
                        item[index].tags[j] = item[index].tags[j+1];
                    }
                    
                    //最後の配列は空にする。
                    item[index].tags[getTagsIndex(index)] = "";
                    //配列削除するときはかならず-1すること。
                    item[index].tags.length = item[index].tags.length - 1;
                    //成功を返す
                    return true;
                }
            }
        }
        //失敗を返す。
        return false;
    }


    // delete smartcontract
    function kill() public{
        if (msg.sender == contractAdmin) {
            selfdestruct(contractAdmin);
        } 
    }
}