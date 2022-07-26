// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; //using ERC721  as a base Standard(after removing the transfer and safe_transfer we can make a soulbound nft )
import "@openzeppelin/contracts/utils/Counters.sol"; // uisng counters to take a record of how much nft minted/Degree issued

contract Warranty is ERC721URIStorage{

    address Shop_owner;
    
    
    using Counters for Counters.Counter;
    Counters.Counter private tokenId; 
    
    // here ERC721 constructor({collection_name} ,{collection_symbol}) call first then our contract's constructor
    constructor() ERC721("WarrantyNFT","WNFT"){
        Shop_owner = msg.sender;
        
    }

    // modifier that only owner can call that particular func
    modifier OwnerOnly{
        require(msg.sender == Shop_owner);
      _;
    }

    // warranty issued to specific address fro a specific serial number item
    mapping(address=>mapping(uint=>bool)) public warrantyIssuedTo;
    
    mapping(uint=>address) public tokenIdToPerson; // who one a specific token id

    mapping(uint=>bool) public isValid; // any nft of specific id is valid or not

    mapping(uint=>uint) public validTill; // any nft of specific id is valid till


    // owner can issue the nft  to a user for a specific product and return that issued id
    function  warrantyIssue(address _to, uint _serialID) external OwnerOnly returns(uint) {
        require(warrantyIssuedTo[_to][_serialID] != true,"warranrt is issued already" );
        warrantyIssuedTo[_to][_serialID] = true;
        tokenId.increment(); //now not zero
        tokenIdToPerson[tokenId.current()] = _to;
        return tokenId.current();
    }

    // set the validity and and validtill( in sec) for any token Id;
    function validityIssue(uint _tokenId, uint _validTill) external OwnerOnly{
        require(_tokenId <= tokenId.current(), "id not exists");
        require(isValid[_tokenId] != true  && validTill[_tokenId] == 0,"already valid");
         
        isValid[_tokenId] = true;
        validTill[_tokenId] = block.timestamp + _validTill;
    }

    // user can claim his/her nft by adding the tokenID and tokenURI
    function claimWarranty(uint _tokenId,   string memory _tokenURI,uint _serialID) public returns(bool){
        require(tokenIdToPerson[_tokenId] == msg.sender,"you are not the owner of this nft" );
        require(warrantyIssuedTo[msg.sender][_serialID] == true,"NO warranty is issued to you for that item");
        require(validTill[_tokenId] <= block.timestamp,"validity over");
        
        
        _mint(msg.sender,_tokenId); // address , tokenId
        _setTokenURI(_tokenId,_tokenURI);


        warrantyIssuedTo[msg.sender][_serialID] = false ;// not mint twice

        return true;  // Id of the minted NFT
    }

    // function for checking the valid time for all  nfts and this function is called by gelato every specific interval 
    function checkValid() public {
         
        for(uint i = 1; i<=tokenId.current();i++){

        if(validTill[i] >= block.timestamp){
            
        }
        else{
            isValid[i] = false;
            
        }
        }
    }

}


