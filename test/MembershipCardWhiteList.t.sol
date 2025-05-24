// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MembershipCard.sol";
import { console } from "forge-std/console.sol";
import { stdJson } from "forge-std/StdJson.sol";

contract MembershipCardWhitelistTest is Test {
    using stdJson for string;

    MembershipCard public membership;

    address whitelistedUser = 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf;
    address notWhitelistedUser = vm.addr(2);

    bytes32[] validProof;
    bytes32[] invalidProof;

    function setUp() public {
        string memory json = vm.readFile("script/merkle-output.json");

        // Read the root from the JSON file
        bytes32 merkleRoot = json.readBytes32(".merkleRoot");
        membership = new MembershipCard("Membership", "MEM", 1000, "ipfs://base/");
        membership.setMerkleRoot(merkleRoot);

        // Read the proof for the whitelisted address
        validProof = json.readBytes32Array(".proofs[\"0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf\"]");

        // Use an empty proof for a non-whitelisted address
        invalidProof = new bytes32[](0);
    }

    function testWhitelistedCanMint() public {
        vm.startPrank(whitelistedUser);
        membership.mintWhitelist(validProof);
        assertEq(membership.ownerOf(0), whitelistedUser);
        vm.stopPrank();
    }

    function testNotWhitelistedCannotMint() public {
        vm.startPrank(notWhitelistedUser);
        vm.expectRevert("Not whitelisted");
        membership.mintWhitelist(invalidProof);
        vm.stopPrank();
    }
    function testMintingExceedsTotalSupply() public {
        // Mint all tokens to reach the total supply
        for (uint256 i = 0; i < 1000; i++) {
            vm.startPrank(whitelistedUser);
            membership.mintWhitelist(validProof);
            vm.stopPrank();
        }

        // Attempt to mint one more token
        vm.startPrank(whitelistedUser);
        vm.expectRevert("Sold out");
        membership.mintWhitelist(validProof);
        vm.stopPrank();
    }
    function testBaseUri() public {
        // Mint token 0 first
        vm.startPrank(whitelistedUser);
        membership.mintWhitelist(validProof);
        vm.stopPrank();

        string memory expectedUri = "ipfs://base/0.json";
        assertEq(membership.tokenURI(0), expectedUri);
    }
    function testBaseUriWithNonExistentToken() public {
        vm.expectRevert(
            abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 9999)
        );
        membership.tokenURI(9999); // Token ID 9999 does not exist
    }
    function testBaseUriWithEmptyBaseUri() public {
        // Create a new contract with an empty base URI
        MembershipCard emptyBaseUriMembership = new MembershipCard("EmptyBase", "EBM", 1000, "");
        emptyBaseUriMembership.setMerkleRoot(membership.merkleRoot());

        vm.startPrank(whitelistedUser);
        emptyBaseUriMembership.mintWhitelist(validProof);
        vm.stopPrank();

        // Check the token URI
        assertEq(emptyBaseUriMembership.tokenURI(0), "");
    }
}