// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; //using ERC721  as a base Standard(after removing the transfer and safe_transfer we can make a soulbound nft )
import "@openzeppelin/contracts/utils/Counters.sol"; // uisng counters to take a record of how much nft minted/Degree issued

contract Warranty is ERC721URIStorage{

    address Shop_owner;
    uint private validTill;
    
    using Counters for Counters.Counter;
    Counters.Counter private tokenId; 
    
    // here ERC721 constructor({collection_name} ,{collection_symbol}) call first then our contract's constructor
    constructor(uint _validTill) ERC721("WarrantyNFT","WNFT"){
        Shop_owner = msg.sender;
        validTill=_validTill;
    }

    // modifier that only owner can call that particular func
    modifier OwnerOnly{
        require(msg.sender == Shop_owner);
      _;
    }

    // warranty issued to specific address fro a specific serial number item
    mapping(address=>mapping(uint=>bool)) public warrantyIssuedTo;


    function  warrantyIssue(address _to, uint _serialID) external OwnerOnly {
        warrantyIssuedTo[_to][_serialID] = true;
    }

    // mapping(address=>string[]) public personToNFTs; // anyone can see specific's address items when claimed
    mapping(uint=>address) public tokenIdToPerson; // who one a specific token id

    function claimWarranty(string memory _tokenURI,uint _item) public returns(uint){
        require(warrantyIssuedTo[msg.sender][_item] == true,"NO warranty is issued to you for that item");

        tokenId.increment(); //now not zero
        uint  newItemId = tokenId.current();
        _mint(msg.sender,newItemId); // address , tokenId
        _setTokenURI(newItemId,_tokenURI);

        




        // personToNFTs[msg.sender].push(_tokenURI) ;
        tokenIdToPerson[newItemId] = msg.sender;

        warrantyIssuedTo[msg.sender][_item] = false ;// not mint twice

        return newItemId;  // Id of the minted NFT
    }

    function burnWarranty(uint _tokenid,uint _serialID, address _ownerOfNft) public returns(bool){
        require(msg.sender==Shop_owner || msg.sender == tokenIdToPerson[_tokenid]); // only owner or  nftOwner can call this func

        _burn(_tokenid);
        warrantyIssuedTo[_ownerOfNft][_serialID] = false;
      

        return true;

    }
}


