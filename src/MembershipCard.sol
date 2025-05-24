// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";


contract MembershipCard is ERC721, Ownable {
    using Strings for uint256; // Importing the Strings library for converting uint256 to string

    uint256 public currentTokenId;
    uint256 public totalSupply; // Set the total supply of NFTs
    string public baseUri; // Base URI for the NFT metadata
    bytes32 public merkleRoot; // Merkle root for whitelisting
    // tokenId => timestamp del stake (0 si no está stakeado)
    mapping(uint256 => uint256) public stakedAt;


    event MintNFT(address userAddress_, uint256 tokenId_);
    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, string memory baseUri_) ERC721(name_, symbol_) Ownable(msg.sender) {
        totalSupply = totalSupply_;
        baseUri = baseUri_;
    }

    function setMerkleRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function mintWhitelist(bytes32[] calldata merkleProof) external {
        require(currentTokenId < totalSupply, "Sold out"); // Check if the total supply has been reached

        // Hash del msg.sender
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        // Verifica si el leaf pertenece al árbol
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "Not whitelisted");

        _safeMint(msg.sender, currentTokenId);

        uint256 id = currentTokenId; // Store the current token ID in a local variable
        currentTokenId++;
        emit MintNFT(msg.sender, id);
    }

    function stake(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(stakedAt[tokenId] == 0, "Already staked");

        stakedAt[tokenId] = block.timestamp;

        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(stakedAt[tokenId] > 0, "Not staked");

        stakedAt[tokenId] = 0;

        emit Unstaked(msg.sender, tokenId);
    }

    function _baseURI() internal view override virtual returns (string memory) {
        return baseUri;
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);

        // Bloquear si está stakeado y no es un mint (from == address(0)) o burn (to == address(0))
        if (from != address(0) && to != address(0)) {
            require(stakedAt[tokenId] == 0, "Token is staked");
        }

        return super._update(to, tokenId, auth);
    }

    function tokenURI(uint256 tokenId) public view override virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }
}