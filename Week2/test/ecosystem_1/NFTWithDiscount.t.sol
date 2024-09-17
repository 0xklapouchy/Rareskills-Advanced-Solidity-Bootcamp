// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import { Test, console } from "forge-std/Test.sol";
import { NFTWithDiscount } from "../../src/ecosystem_1/NFTWithDiscount.sol";

contract NFTWithDiscountTest is Test {
    NFTWithDiscount public nft;
    address owner;
    address alice;
    address bob;

    bytes32[] public merkleTree;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice"); // 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6
        bob = makeAddr("bob"); // 0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e

        /// tree with 4 leaves and 3 levels
        merkleTree = new bytes32[](7);
        uint256 index = 0;
        merkleTree[6] = keccak256(bytes.concat(keccak256(abi.encode(alice, ++index))));
        merkleTree[5] = keccak256(bytes.concat(keccak256(abi.encode(bob, ++index))));
        merkleTree[4] = keccak256(bytes.concat(keccak256(abi.encode(alice, ++index))));
        merkleTree[3] = keccak256(bytes.concat(keccak256(abi.encode(bob, ++index))));
        merkleTree[2] = (merkleTree[5] > merkleTree[6]) ? keccak256(abi.encode(merkleTree[6], merkleTree[5])) : keccak256(abi.encode(merkleTree[5], merkleTree[6]));
        merkleTree[1] = (merkleTree[3] > merkleTree[4]) ? keccak256(abi.encode(merkleTree[4], merkleTree[3])) : keccak256(abi.encode(merkleTree[3], merkleTree[4]));
        merkleTree[0] = (merkleTree[1] > merkleTree[2]) ? keccak256(abi.encode(merkleTree[2], merkleTree[1])) : keccak256(abi.encode(merkleTree[1], merkleTree[2]));

        nft = new NFTWithDiscount(merkleTree[0]);

        vm.deal(alice, 5 ether);
        vm.deal(bob, 5 ether);
    }

    function test_Deploy() public view {
        assertEq(nft.owner(), address(this));
        assertEq(nft.merkleRoot(), merkleTree[0]);
        assertEq(nft.totalSupply(), 0);
    }

    function test_MaxSupply() public {
        nft.mint{value: 0.1 ether}(alice);

        bytes32[] memory prof = new bytes32[](2);
        prof[0] = merkleTree[6];
        prof[1] = merkleTree[1];
        vm.prank(bob);
        nft.mintWithDiscount{value: 0.01 ether}(bob, prof, 2);

        for (uint256 i = 0; i < 998; i++) {
            nft.mint{value: 0.1 ether}(alice);
        }

        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.MaxSupplyReached.selector));
        nft.mint{value: 0.1 ether}(alice);

        prof = new bytes32[](2);
        prof[0] = merkleTree[4];
        prof[1] = merkleTree[2];
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.MaxSupplyReached.selector));
        nft.mintWithDiscount{value: 0.01 ether}(bob, prof, 3);
    }

    function test_InvalidPrice() public {
        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.InvalidPrice.selector));
        nft.mint{value: 0.09 ether}(alice);

        bytes32[] memory prof = new bytes32[](2);
        prof[0] = merkleTree[6];
        prof[1] = merkleTree[1];
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.InvalidPrice.selector));
        nft.mintWithDiscount{value: 0.05 ether}(bob, prof, 2);
    }

    function test_AlreadyDiscounted() public {
        bytes32[] memory prof = new bytes32[](2);
        prof[0] = merkleTree[6];
        prof[1] = merkleTree[1];
        vm.prank(bob);
        nft.mintWithDiscount{value: 0.01 ether}(bob, prof, 2);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.AlreadyDiscounted.selector));
        nft.mintWithDiscount{value: 0.01 ether}(bob, prof, 2);
    }

    function test_InvalidProof() public {
        bytes32[] memory prof = new bytes32[](2);
        prof[0] = merkleTree[6];
        prof[1] = merkleTree[1];
        vm.expectRevert(abi.encodeWithSelector(NFTWithDiscount.InvalidProof.selector));
        nft.mintWithDiscount{value: 0.01 ether}(bob, prof, 2);
    }

    function test_Withdraw() public {
        uint256 balance = address(this).balance;
        vm.prank(alice);
        nft.mint{value: 0.1 ether}(alice);
        nft.withdraw();
        assertEq(address(this).balance, balance + 0.1 ether);
    }

    receive() external payable {}
}
