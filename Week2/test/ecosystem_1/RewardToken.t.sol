// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import { Test, console } from "forge-std/Test.sol";
import { RewardToken } from "../../src/ecosystem_1/RewardToken.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract RewardTokenTest is Test {
    RewardToken public rt;
    address owner;
    address alice;
    address bob;

    bytes32[] public merkleTree;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice"); // 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6

        rt = new RewardToken(owner);
    }

    function test_Mint_If_Owner() public {
        rt.mint(alice, 100);
        assertEq(rt.balanceOf(alice), 100);
    }

    function test_Revert_If_Not_Owner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        rt.mint(alice, 100);
    }
}
