//pragma solidity ^0.4.23;
pragma solidity ^0.4.20;

import "./ERC721Token.sol";

contract MyToken is ERC721Token {
    
  uint256 internal nextTokenId = 0;

  // @_name ファイル名
  // @_symbol 略称
  constructor() public ERC721Token("ContentsHub","CHB") {}

  function mint(string _contentsName, string _contentsDetails, uint256 _contentsPrice, string _contentsMetadata) external {
    uint256 tokenId = nextTokenId;
    nextTokenId = nextTokenId.add(1);
    super._mint(msg.sender, tokenId, _contentsName, _contentsDetails, _contentsPrice, _contentsMetadata);
  }

  function setTokenURI(uint256 _tokenId, string _message) external onlyOwnerOf(_tokenId) {
    super._setTokenURI(_tokenId, _message);
  }

  function burn(uint256 _tokenId) external onlyOwnerOf(_tokenId) {
    super._burn(msg.sender, _tokenId);
  }
 
  
}