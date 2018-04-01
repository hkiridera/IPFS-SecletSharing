pragma solidity ^0.4.10;
pragma experimental ABIEncoderV2;

// todo
// Data用コントラクト
// ロジック用コントラクトから呼び出す想定

contract Data {
    address contractAdmin;      //コントラクトのオーナ
    address contractAddress;    //コントラクトのアドレス
    //address[] contributer;      //データオーナの一覧
    //mapping (address => uint256) public contribution ;  //データオーナーの貢献度
    mapping (address => uint256) amount;         //送金者の残高
    address[] senderList;                        //送金者一覧

    uint8 remunerationRate = 1;     //コントラクトオーナーの報酬率
    uint8 savingRate       = 1;     //コントラクトの貯蓄率

    struct Item {
        address     dataOwner;      //登録者のアドレスを記録
        string      dataAddress;    //データアドレス
        
        string      name;           //ファイル名
        string      details;        //詳細
        string[]    tags;           //タグ
        uint        price;          //価格(wei)
        uint        updatedDate;    //登録日時
        uint64      dlCount;        //DL数
        string[]    comment;        //コメント
        string      metadata;       //メタデータ
        string[]    extraData;      //その他データ
        mapping (address => bool) purchaser;    // 購入者リスト

        //管理用
        bool    locked;             //編集可否フラグ
        bool    deleted;            //削除フラグ
        //購入者リスト
    }

    Item[] item;

    // initialize
    function Data() public {
        contractAdmin = msg.sender;
        contractAddress = address(this);
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* データの中身を取得 */
    // index番号をを引数に、保存先アドレスを返す。
    //@index itemの番号
    //@return 保存先のアドレス
    function getItemAddress(uint index) public view returns (string ) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return "Error ItemAddress Not Found";
        }
        //買ってたらアドレスを返す
        //ContractOwner もしくかItem管理者ならok
        if (item[index].purchaser[msg.sender] == true || checkItemOwner(index) == true ){
            return item[index].dataAddress;
        }
        //未購入ならエラー
        return "Error Not purchased yet";
    }

/*
    // index番号を引数に、タグを返す。
    //@index itemの番号
    //@return itemのtag一覧(uint)Comment
    function getItemTags(uint index) public view returns (string[] ) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        return item[index].tags;
    }
*/
    // index番号とタグ番号を引数に、タグを返す。
    //@index itemの番号
    //@num   itemのtag番号
    //@return タグ
    function getItemTag(uint index, uint8 num) public view returns (string) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        return item[index].tags[num];
    }

    // index番号を引数に、詳細を返す
    function getItemDetails(uint index) public constant returns (string ) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return "Error ItemDetails Not Found";
        }
        return item[index].details;
    }

    // index番号を引数に、item名を返す
    function getItemName(uint index) public constant returns (string ) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return "Error ItemName Not Found";
        }    
        return item[index].name;
    }

    //lock状態を確認する
    function getItemLock(uint index) public constant returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        return item[index].locked;
    }

    //データ所有者を確認する
    function getItemDataOwner(uint index) public constant returns (address) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        return item[index].dataOwner;
    }

    //削除の確認
    function getItemDeleted(uint index) public constant returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }

        if ( checkItemOwner(index) ){
            return item[index].deleted;
        }
        return false;
    }

    //登録日時を返す
    function getItemupdatedDate(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return 0;
        }
        return item[index].updatedDate;
    }

    //DL数を返す
    function getItemDlCount(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return 0;
        }
        return item[index].dlCount;
    }

    // コメントを返す
    //i = index番号
    //j= コメント番号
    function getItemComment(uint index, uint num) public view returns (string) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        return item[index].comment[num];
    }

    //価格を返す
    function getPrice(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        if (item[index].deleted == false || msg.sender == contractAdmin ) {
            return item[index].price;
        }else {
            return 0;
        }
    }

    //extraDataを返す
    function getItemExtraData(uint index, uint num) public view returns (string) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        return item[index].extraData[num];
    }

    //Metadataを返す
    function getItemMetadata(uint index) public constant returns (string) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return "Error Metadata Not Found";
        }
        return item[index].metadata;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* 検索 */

    //登録されているデータ数を返す
    function getItemLength() public constant returns (uint) {
        return item.length;
    }

    //index番号のitemに付いているタグ総数を返す
    function getItemTagsLength(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return 0;
        }
        return item[index].tags.length;
    }

    //index番号のitemに付いているコメント総数を返す
    function getItemCommentLength(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return 0;
        }
        return item[index].comment.length;
    }

    //index番号のitemに付いているextraDataの総数を返す
    function getItemExtraDataLength(uint index) public constant returns (uint) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return 0;
        }
        return item[index].extraData.length;
    }

    //dataOwnerの一覧を返す
    function getDataOwnerLength() public view returns (address[]) {
        //コントラクト管理者のみ実行可能
        if (msg.sender == contractAdmin) {
            address[] memory ownerList;
            for (uint i; i < item.length; i++) {
                ownerList[i] = (item[i].dataOwner);
            }
            return ownerList;
        } 
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* データ登録,更新 */

    // 新規データ登録
    // 登録したindex番号を返す
    function putItem(string memory vAddress, string memory vName, string memory vDetails, uint vPrice) public returns (uint) {
        //登録済みの場合は何もしない。
        if ( searchFromdataAddress(vAddress) ) {
            return 0;
        }

        Item memory tmp;

        //引数から入力
        tmp.dataAddress = vAddress;
        tmp.name = vName;
        tmp.details = vDetails;
        tmp.price = vPrice;
        tmp.locked = false;

        //自動入力項目
        tmp.dlCount = 0;
        tmp.dataOwner = msg.sender;
        tmp.deleted = false;
        tmp.updatedDate = now;
        
        item.push(tmp);

        //データオーナー一覧に追加
        //putContributer();

        //登録したindex番号を返す
        return getItemLength();
    }

    // Itemの購入
    //@index itemの番号
    function buyItem(uint index) public{
        //データの存在確認
        if (!checkItemExistence(index)) {
            return;
        }
        //残高が価格を超えているか確認
        //未購入であるか確認
        if (amount[msg.sender] >= item[index].price && item[index].purchaser[msg.sender] == false) {
            //保存先のアドレスを参照したら、DL数を+1する
            item[index].dlCount++;
            //購入者リストに追加
            item[index].purchaser[msg.sender] = true;
            //実行者の残高から価格を引く
            amount[msg.sender] -= item[index].price;
            //データオーナーに送金
            item[index].dataOwner.transfer(item[index].price);
        }
        return;
    }

    // index番号のitemにコメントを付与する
    //成功時: true, 失敗時: false
    function putComments(uint index, string memory vComment) public returns(bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //コメント欄の最後に追記する
        item[index].comment.push(vComment);
        //更新時間を更新する。
        item[index].updatedDate = now;
        //成功時にtrueを返す
        return true;
    }

    // index番号のitemにタグを付与する
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function putTags(uint index, string memory vTag) public returns(bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }

        //既にItemに登録済みでないことを確認する
        for (uint i; i < getItemTagsLength(index); i++) {
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
        item[index].updatedDate = now;
        //成功時にtrueを返す
        return true;
    }

    //価格を登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function updatePrice(uint index, uint vPrice) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return ;
        }
        //更新者が管理者orオーナであること
        if ( checkItemOwner(index) ) {
            item[index].price = vPrice;
            //更新時間を更新する。
            item[index].updatedDate = now;
            return true;
        }
        return false;
    }

    //lockedを登録する。
    //管理者のみ実行可能
    //成功時: true, 失敗時: false
    function updateLocked(uint index, bool vLocked) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        item[index].locked = vLocked;
        //更新時間を更新する。
        item[index].updatedDate = now;
        return true;
    }

    //deletedを登録する。
    //管理者のみ実行可能
    //成功時: true, 失敗時: false
    function putDeleted(uint index, bool vDeleted) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //更新者が管理者orオーナであること
        if ( checkItemOwner(index) ) {
            item[index].deleted = vDeleted;
            //更新時間を更新する。
            item[index].updatedDate = now;
            return true;
        }
        return false;
    }

    //nameを登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function updateName(uint index, string memory vName) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //更新者が オーナーor管理者であること
        if ( checkItemOwner(index) ) {
            item[index].name = vName;
            //更新時間を更新する。
            item[index].updatedDate = now;
            return true;
        }
        return false;
    }

    //detailsを登録する。
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function updateDetails(uint index, string memory vDetails) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //更新者が オーナーor管理者であること
        if ( checkItemOwner(index) ) {
            item[index].details = vDetails;
            //更新時間を更新する。
            item[index].updatedDate = now;
            return true;
        }
        return false;
    }

    // index番号のitemにExtraDataを付与する
    //成功時: true, 失敗時: false
    function putExtraData(uint index, string memory vExData) public returns(bool) {
        //データの存在確認&更新可否確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //extraData欄の最後に追記する
        item[index].extraData.push(vExData);
        //更新時間を更新する。
        item[index].updatedDate = now;
        //成功時にtrueを返す
        return true;
    }

    // index番号のitemにMetadataを付与する
    //成功時: true, 失敗時: false
    function putMetadataData(uint index, string memory vMetadata) public returns(bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //更新者が オーナーor管理者であること
        if ( checkItemOwner(index) ) {
            //Metadataの最後に追記する
            item[index].metadata = vMetadata;
            //更新時間を更新する。
            item[index].updatedDate = now;
            //成功時にtrueを返す
            return true;
        }
        //失敗時にfalseを返す
        return false;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* 管理者コマンド */

    //タグの削除
    //管理者 or 所有者のみ実行可能
    //成功時: true, 失敗時: false
    function deleteTags(uint index, string memory vTag) public returns (bool) {
        //データの存在確認
        if (!checkItemExistence(index)) {
            return false;
        }
        //削除されていないこと
        //lockされていないこと
        //更新者が オーナーor管理者であること
        if ( checkItemOwner(index) ) {
            //タグを全部検索する
            for ( uint i = 0; i < getItemTagsLength(index); i++ ) {
                //一致するタグを検索
                if ( keccak256(item[index].tags[i]) == keccak256(vTag) ) {
                    //最後のindexでないことを確認する。
                    if (i == getItemTagsLength(index)) {
                        return false;
                    }
                    //タグ番号を1個前にずらす。                        
                    for ( uint j = i; j < getItemTagsLength(index) - 1; j++ ) {
                        item[index].tags[j] = item[index].tags[j+1];
                    }
                    
                    //最後の配列は空にする。
                    item[index].tags[getItemTagsLength(index)] = "";
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


    // コントラクトオーナーの報酬率を修正
    function changeRemunerationRate(uint8 num) public returns (uint8){
        if (msg.sender == contractAdmin) {
            remunerationRate = num;
            return remunerationRate;
        }
        return 0;
    }

    // コントラクトオーナーの貯蓄率を修正
    function changeSavingRate(uint8 num) public returns (uint8){
        if (msg.sender == contractAdmin) {
            savingRate = num;
            return savingRate;
        }
        return 0;
    }

    // コントラクトオーナーを返す
    function getContractOwner() public returns (address){
        if (msg.sender == contractAdmin) {
            return contractAdmin;
        }
    }

    // delete smartcontract
    // 返金してから破棄する
    function kill() public{
        if (msg.sender == contractAdmin) {

            for (uint i; i < senderList.length; i++){
                //残高が0以上なら返金
                if (amount[senderList[i]] > 0) {
                    //返金処理
                    senderList[i].transfer(amount[senderList[i]]);
                    //残高を0にする
                    amount[senderList[i]] = 0;
                }
            }

            selfdestruct(contractAdmin);
        } 
    }


    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* お金関係 */
    
    //残高確認
    function getAmount() public view returns (uint){
        return amount[msg.sender];
    }

    //返金
    function withDraw() public {
        //実行者に返金する
        if(amount[msg.sender] > 0){
            msg.sender.transfer(amount[msg.sender]);
            amount[msg.sender] = 0;
        }
    }

    //入金時の処理
    //手数料として入金額の1%をownerに渡す
    function depodit() public payable{
        uint value = msg.value;
        //手数料として入金額の1%をownerに渡す
        // (100eth/100) * 1 = (1) * 1 = 1eth
        contractAdmin.transfer((value/100)*remunerationRate);
        value -= (value/100)*remunerationRate;

        //送金者の送金額から手数料を引いた額を残高として記録
        amount[msg.sender] = value;

        //送金者一覧に追加
        senderList.push(msg.sender);
    }

    //フォールバックファンクション
    //入金処理を呼び出す
    function () public payable{
        depodit();
    }

    /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /* 内部関数 */

    // indexのitemが存在するかを確認する&削除済みでないことを確認する
    // contractAdminは例外で参照可能
    // @index itemのindex番号
    // @return bool 存在する:true 存在しない:false
    function checkItemExistence(uint vIndex) internal view returns (bool){
        //データの存在確認
        if ( getItemLength() >= vIndex) {
            //削除されていないこと
            //更新者が管理者であること
            if ( (item[vIndex].deleted == false) || (msg.sender == contractAdmin) ) {
                return true;
            }
        }
        return false;
    }

    // 実行者がItemのOwnerもしくはContractAdminであることの確認
    // ContractAdminが実行者の場合は例外的に許可する
    // @index itemのindex番号
    // @return bool 存在する:true 存在しない:false
    function checkItemOwner(uint vIndex) internal view returns (bool){
        //データの存在確認
        if ( getItemLength() >= vIndex) {
            //更新者が管理者であること
            //更新者がcontractAdminであること
            if ( ( (item[vIndex].dataOwner == msg.sender) || (msg.sender == contractAdmin) ) ) {
                return true;
            }
        }
        return false;
    }

    //データアドレスから検索
    //@vAddress データのアドレス
    //@return 存在する:true 存在しない:false
    function searchFromdataAddress(string memory vAddress) internal view returns (bool) {
        // itemの数だけループする。
        for ( uint i = 0; i < item.length; i++ ) {
            //データアドレスが登録済みであることを確認する。
            if (keccak256(item[i].dataAddress) == keccak256(vAddress) ) {
                // 一致した場合はtrueを返す
                return true;
            }
        }        
        //存在しない場合はfalseを返す。
        return false;
    }

    //Owner毎の貢献度を更新する
    /*
    function setContributionByOwner() public returns (bool) {
        for (uint i; i < item.length; i++) {
            contribution [item[i].dataOwner] += item[i].dlCount;
        }
        return true;
    }
    */

    //item登録者をデータオーナ一覧に追加
    /*
    function putContributer() internal{
        //データオーナー一覧に追加
        bool flg = false;
        for (uint i; i < contributer.length; i++){
            if (contributer[i] == msg.sender){
                flg = true;
            }
        }
        if (flg == false) {
            contributer.push(msg.sender);
        }
    }
    */


    /*
    //残りは貢献度に応じて分配
    function () public payable{
        uint amount = msg.value;
        //手数料として入金額の1%をownerに渡す
        // (100eth/100) * 1 = (1) * 1 = 1eth
        contractAdmin.transfer((amount/100)*remunerationRate);
        amount -= (amount/100)*remunerationRate;

        //手数料用にコントラクトが1%を貯金
        // 99 - (99eth/100) * 1 = 99 - (0.99) * 1 = 98.01eth
        amount -= (amount/100)*savingRate;

        //貢献度の合計を計算
        uint contributionSum;
        for (uint i; i < contributer.length; i++) {
            contributionSum += contribution[contributer[i]];
        }

        //貢献度の割合に応じて分配
        for (uint j; j < contributer.length; j++) {
            contributer[j].transfer((amount/contributionSum)*contribution[contributer[j]]);
        }
    }
    */
}