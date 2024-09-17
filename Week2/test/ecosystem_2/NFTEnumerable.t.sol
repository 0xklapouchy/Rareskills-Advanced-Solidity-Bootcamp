// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import { Test, console } from "forge-std/Test.sol";
import { NFTEnumerable } from "../../src/ecosystem_2/NFTEnumerable.sol";

contract NFTEnumerableTest is Test {
    NFTEnumerable nft;
    address owner;
    address alice;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice"); // 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6

        nft = new NFTEnumerable();
    }

    function test_Deploy() public view {
        assertEq(nft.totalSupply(), 0);
    }

    function test_MaxSupply_And_Ids() public {
        for (uint256 i = 0; i < 100; i++) {
            nft.mint(alice);
        }

        vm.expectRevert(abi.encodeWithSelector(NFTEnumerable.MaxSupplyReached.selector));
        nft.mint(alice);

        for (uint256 i = 0; i < 100; i++) {
            assertEq(nft.tokenOfOwnerByIndex(alice, i), i + 1);
        }
    }
}
