// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MembershipCard.sol";
import { stdJson } from "forge-std/StdJson.sol";

contract MembershipCardStakingTest is Test {
    using stdJson for string;

    MembershipCard public membership;

    address user = vm.addr(1);
    address attacker = vm.addr(2);
    bytes32[] proof;

    function setUp() public {
        string memory json = vm.readFile("script/merkle-output.json");

        // Read the root from the JSON file
        bytes32 merkleRoot = json.readBytes32(".merkleRoot");
        membership = new MembershipCard("Membership", "MEM", 1000, "ipfs://base/");
        membership.setMerkleRoot(merkleRoot);

        // Read the proof for the whitelisted address
        proof = json.readBytes32Array(".proofs[\"0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf\"]");

        // Mint with correct proof
        vm.prank(user);
        membership.mintWhitelist(proof);
    }

    function testStake() public {
        vm.startPrank(user);
        uint256 tokenId = 0; // El primer token mintado
        membership.stake(tokenId);
        assertEq(membership.stakedAt(tokenId), block.timestamp);
        vm.stopPrank();
    }

    function testUnstake() public {
        vm.startPrank(user);
        uint256 tokenId = 0; // El primer token mintado
        membership.stake(tokenId);
        membership.unstake(tokenId);
        assertEq(membership.stakedAt(tokenId), 0); // Verifica que el stake se haya eliminado
        vm.stopPrank();
    }

    function testCannotStakeIfNotOwner() public {
        vm.startPrank(attacker);
        uint256 tokenId = 0; // El primer token mintado
        vm.expectRevert("Not the owner");
        membership.stake(tokenId);
        vm.stopPrank();
    }

    function testCannotUnstakeIfNotStaked() public {
        vm.startPrank(user);
        uint256 tokenId = 0; // El primer token mintado
        vm.expectRevert("Not staked");
        membership.unstake(tokenId);
        vm.stopPrank();
    }

    function testCannotUnstakeIfNotOwner() public {
        vm.startPrank(attacker);
        uint256 tokenId = 0; // El primer token mintado
        vm.expectRevert("Not the owner");
        membership.unstake(tokenId);
        vm.stopPrank();
    }
    function testCannotStakeAlreadyStaked() public {
        vm.startPrank(user);
        uint256 tokenId = 0; // El primer token mintado
        membership.stake(tokenId);
        vm.expectRevert("Already staked");
        membership.stake(tokenId);
        vm.stopPrank();
    }

    function testCannotUnstakeAlreadyUnstaked() public {
        vm.startPrank(user);
        uint256 tokenId = 0; // El primer token mintado
        membership.stake(tokenId);
        membership.unstake(tokenId);
        vm.expectRevert("Not staked");
        membership.unstake(tokenId);
        vm.stopPrank();
    }

    function testCannotStakeNonExistentToken() public {
        vm.startPrank(user);
        uint256 tokenId = 9999; // Un token que no existe
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 9999));
        membership.stake(tokenId);
        vm.stopPrank();
    }

    function testCannotUnstakeNonExistentToken() public {
        vm.startPrank(user);
        uint256 tokenId = 9999; // Un token que no existe
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 9999));
        membership.unstake(tokenId);
        vm.stopPrank();
    }

    function testCannotTransferStakedToken() public {
        vm.startPrank(user);
        membership.stake(0);
        vm.stopPrank();

        // Intenta transferir como owner
        vm.startPrank(user);
        vm.expectRevert("Token is staked");
        membership.transferFrom(user, attacker, 0);
        vm.stopPrank();
    }

    function testCanTransferUnstakedToken() public {
        // El token no está stakeado, debería poder transferirse
        vm.startPrank(user);
        membership.transferFrom(user, attacker, 0);
        vm.stopPrank();

        assertEq(membership.ownerOf(0), attacker);
    }

    function testFuzzStakeInvalidTokenId(uint256 tokenId) public {
        vm.assume(tokenId != 0); // 0 ya lo has minteado
        vm.prank(user);
        vm.expectRevert(); // debería revertir con token inexistente
        membership.stake(tokenId);
    }

}