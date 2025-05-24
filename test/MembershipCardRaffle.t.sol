// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MembershipCard.sol";
import { stdJson } from "forge-std/StdJson.sol";

contract MembershipCardRaffleTest is Test {
    using stdJson for string;

    MembershipCard public membership;

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    bytes32[] proof;

    function setUp() public {
        string memory json = vm.readFile("script/merkle-output.json");
        bytes32 merkleRoot = json.readBytes32(".merkleRoot");

        membership = new MembershipCard("Membership", "MEM", 1000, "ipfs://base/");
        membership.setMerkleRoot(merkleRoot);

        // user1 mintea
        proof = json.readBytes32Array(".proofs[\"0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf\"]");
        vm.prank(user1);
        membership.mintWhitelist(proof);
    }

    function testRevertIfNoStakers() public {
        vm.expectRevert("No stakers");
        membership.pickRandomStakerWinner();
    }

    function testPickWinnerFromStaked() public {
        // Stake NFT
        vm.prank(user1);
        membership.stake(0);

        // Call the raffle
        (address winner, uint256 tokenId) = membership.pickRandomStakerWinner();

        assertEq(winner, user1);
        assertEq(tokenId, 0);
    }
}
