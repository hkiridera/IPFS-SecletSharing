//pragma solidity ^0.4.23;
pragma solidity ^0.4.20;
pragma experimental ABIEncoderV2;

import "./ERC721Token.sol";
import "./AccessControl.sol";

contract MyToken is ERC721Token, AccessControl{
    
    uint256 internal nextTokenId = 0;
    
    // @_name ファイル名
    // @_symbol 略称
    constructor() public ERC721Token("ContentsHub","CHB") {
        ceoAddress = msg.sender;
        cfoAddress = msg.sender;
        cooAddress = msg.sender;
    }

    /**
    * @dev Checks msg.value more than contentsPrice
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    modifier purchaseAvailable(uint256 _tokenId) {
        require(contents[_tokenId].contentsPrice <= msg.value);
        _;
    }
  
    /**
    * @dev contents was purchased
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    modifier purchased(uint256 _tokenId) {
        require(
            contents[_tokenId].contentsPurchaser[msg.sender] == true ||
            ownerOf(_tokenId) == msg.sender ||
            ceoAddress == msg.sender
        );
        _;
    }
  
  
    function mint(string _contentsName, string _contentsDetails, string _contentsURL, uint256 _contentsPrice, string _contentsMetadata) external {
        uint256 tokenId = nextTokenId;
        nextTokenId = nextTokenId.add(1);
        super._mint(msg.sender, tokenId, _contentsName, _contentsDetails, _contentsURL, _contentsPrice, _contentsMetadata);
    }

    function setTokenURI(uint256 _tokenId, string _message) external onlyOwnerOf(_tokenId) {
        super._setTokenURI(_tokenId, _message);
    }

    function burn(uint256 _tokenId) external onlyOwnerOf(_tokenId) {
        super._burn(msg.sender, _tokenId);
    }
 
 
    /**
    * @dev Purchase the right to download content
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function purchaseContents(uint256 _tokenId) public payable purchaseAvailable(_tokenId){
      
        if(contents[_tokenId].contentsPrice !=0){
            // send contentPrice to CEO 1%
            uint256 fee = contents[_tokenId].contentsPrice / 100;
            cfoAddress.transfer(fee);
            // send purchasePrice to TokenOwner 
            uint256 purchasePrice = contents[_tokenId].contentsPrice - fee;
            // send fee to TokenOwner
            tokenOwner[_tokenId].transfer(purchasePrice);
        }
      
        // Purchased
        contents[_tokenId].contentsPurchaser[msg.sender] = true;
    }

    /**
    * @dev return contentsName
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsName(uint256 _tokenId) public view returns(string){
        return contents[_tokenId].contentsName;
    }
  
    /**
    * @dev Update Contents Name. 
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    * @param _contentsName string name of the contents
    */
    function updateContentsName(uint256 _tokenId, string _contentsName) public onlyOwnerOf(_tokenId){
        contents[_tokenId].contentsName = _contentsName;
    }

    /**
    * @dev return contentsDetails
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsDetails(uint256 _tokenId) public view returns(string){
        return contents[_tokenId].contentsDetails;
    }
  
    /**
    * @dev update contents contentsDetails
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    * @param _contentsDetails string details of the contents
    */
    function updateContentsDetails(uint256 _tokenId, string _contentsDetails) public onlyOwnerOf(_tokenId){
        contents[_tokenId].contentsDetails = _contentsDetails;
    }
  
    /**
    * @dev return contents URL
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsURL(uint256 _tokenId) public view purchased(_tokenId) returns(string){
        return contents[_tokenId].contentsURL;
    }
   
    /**
    * @dev update contents URL
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    * @param _contentsURL string url of the contents
    */
    function updateContentsURL(uint256 _tokenId, string _contentsURL) public onlyOwnerOf(_tokenId){
        contents[_tokenId].contentsURL = _contentsURL;
    }
  
    /**
    * @dev return contentsPrice
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsPrice(uint256 _tokenId) public view returns(uint256){
        return contents[_tokenId].contentsPrice;
    }  
  
    /**
    * @dev update contents price
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    * @param _contentsPrice uint256 price of the contents
    */
    function updateContentsPrice(uint256 _tokenId, uint256 _contentsPrice) public onlyOwnerOf(_tokenId){
        contents[_tokenId].contentsPrice = _contentsPrice;
    }
   

    /**
    * @dev return contentsMetadata
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsMetadata(uint256 _tokenId) public view purchased(_tokenId) returns(string){
        return contents[_tokenId].contentsMetadata;
    }
  
    /**
    * @dev return contentsPrice
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender
    */
    function getContentsPurchaser(uint256 _tokenId) public view returns(bool){
        return contents[_tokenId].contentsPurchaser[msg.sender];
    }   
  
  
    /**
    * @dev return all contents of the name
    */
    function getAllContentsName() public view returns(string[]){
        string[] _tmp;
        for(uint256 i=0; i<totalSupply(); i++){
            _tmp.push(contents[i].contentsName);
        }
    }
    
    /**
    * @dev return Range of the contents name
    */
    function getRangeContentsName(uint256 _start, uint256 _end) public view returns(string[]){
        string[] _tmp;
        if(_end > totalSupply()){
            _end = totalSupply();
        }
        
        for(uint256 i=_start; i < _end; i++){
            _tmp.push(contents[i].contentsName);
        }
        return _tmp;
    }
    
}