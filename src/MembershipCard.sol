// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MembershipCard is ERC721, Ownable {
    using Strings for uint256; // Importing the Strings library for converting uint256 to string

    uint256 public currentTokenId;
    uint256 public totalSupply; // Set the total supply of NFTs
    string public baseUri; // Base URI for the NFT metadata

    event MintNFT(address userAddress_, uint256 tokenId_);
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, string memory baseUri_) ERC721(name_, symbol_) Ownable(msg.sender) {
        totalSupply = totalSupply_;
        baseUri = baseUri_;
    }
    
    function mint() external {
        require(currentTokenId < totalSupply, "Sold out"); // Check if the total supply has been reached
        _safeMint(msg.sender, currentTokenId);
        uint256 id = currentTokenId; // Store the current token ID in a local variable
        currentTokenId++;

        // Emit the event after minting the NFT
        emit MintNFT(msg.sender, id);
    }
    
    function _baseURI() internal view override virtual returns (string memory) {
        return baseUri;
    }
    

    function tokenURI(uint256 tokenId) public view override virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }
}