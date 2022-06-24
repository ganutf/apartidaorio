
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


pragma solidity >=0.7.0 <0.9.0;

contract ApartidaorioNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.001 ether;
  bool public paused = false;
  bool public revealed = false;
  string public notRevealedUri;
  mapping (uint256 => string) internal _tokenURIs;

  struct  PoliticalEvent
  {
    string source_name;
    string event_description;
    string statement;
    string author;
    string date;
    string source_url;
  }

  mapping (uint256 => PoliticalEvent) internal _politicalEvents;


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initNotRevealURI
  ) ERC721(_name, _symbol) {
    setNotRevealedURI(_initNotRevealURI);
  }


  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function sourceName(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].source_name;
    
  }

  function eventDescription(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].event_description;
    
  }
  function eventStatement(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].statement;
    
  }

  function eventAuthor(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].author;
    
  }

  function eventDate(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].date;
  }

  function eventSourceUrl(uint256 _tokenId) public view returns (string memory) {
    
    return  _politicalEvents[_tokenId].source_url;
  }


  // public
  function mint(uint256 _tokenId,  string memory _tokenURI) public payable onlyOwner {
    //uint256 supply = totalSupply();

    require(!paused, "contract paused");
    _safeMint(msg.sender, _tokenId);
    setTokenURI(_tokenId, _tokenURI);

  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if(revealed == false) {
        return notRevealedUri;
    }

    
    string memory currentTokenURI = _tokenURIs[_tokenId];

    require(
      bytes(currentTokenURI).length > 0,
      "ERC721Metadata: tokenUri not found"
    );


    return currentTokenURI;
        

    //string memory currentBaseURI = _baseURI();
    //return bytes(currentBaseURI).length > 0
      //  ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        //: "";
  }

  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }


  function setBaseURI(string memory _newBaseURI) internal {
    baseURI = _newBaseURI;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setPoliticalEvent(uint256 tokenId, 
                            string memory source_name, 
                            string memory event_description,
                            string memory statement,
                            string memory author,
                            string memory date,
                            string memory source_url) public onlyOwner {

    require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
    
    require(
      _exists(tokenId),
      "ERC721Metadata: URI set of nonexistent token"
    );

    PoliticalEvent  memory p_event;
    p_event = PoliticalEvent(source_name, event_description,statement,author,date, source_url);
    _politicalEvents[tokenId] = p_event;
  }



  function setTokenURI(uint256 tokenId, string memory _tokenURI) internal{
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

    require(
      _exists(tokenId),
      "ERC721Metadata: URI set of nonexistent token"
    );

    _tokenURIs[tokenId] = _tokenURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

 
  function withdraw() public payable onlyOwner {
    // This will pay HashLips 5% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    //(bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
    //require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
