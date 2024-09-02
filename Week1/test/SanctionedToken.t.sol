// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { SanctionedToken } from "../src/SanctionedToken.sol";

contract SanctionedTokenTest is Test {
    error AccountBlacklisted(address account);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Blacklisted(address indexed account, bool isBlacklisted);

    SanctionedToken public st;
    address owner;
    address alice;
    address bob;

    modifier whenBlacklisted(address account) {
        vm.prank(owner);
        st.setBlacklisted(account, true);
        _;
    }

    function setUp() public {
        st = new SanctionedToken();
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        st.transfer(alice, 100 ether);
        st.transfer(bob, 100 ether);

        vm.prank(alice);
        st.approve(bob, 10 ether);

        vm.prank(bob);
        st.approve(alice, 25 ether);
    }

    function test_SetBlacklisted() public {
        vm.expectEmit();
        emit Blacklisted(alice, true);
        st.setBlacklisted(alice, true);
        assertTrue(st.blacklisted(alice));

        vm.expectEmit();
        emit Blacklisted(alice, false);
        st.setBlacklisted(alice, false);
        assertFalse(st.blacklisted(alice));
    }

    function test_Transfer_NotBlacklisted() public {
        vm.expectEmit();
        emit Transfer(alice, bob, 10 ether);
        vm.prank(alice);
        st.transfer(bob, 10 ether);

        vm.expectEmit();
        emit Transfer(bob, alice, 25 ether);
        vm.prank(bob);
        st.transfer(alice, 25 ether);
    }

    function test_Transfer_ToBlacklisted() public whenBlacklisted(bob) {
        vm.expectRevert(abi.encodeWithSelector(AccountBlacklisted.selector, bob));
        vm.prank(alice);
        st.transfer(bob, 10 ether);
    }

    function test_Transfer_FromBlacklisted() public whenBlacklisted(alice) {
        vm.expectRevert(abi.encodeWithSelector(AccountBlacklisted.selector, alice));
        vm.prank(alice);
        st.transfer(bob, 10 ether);
    }

    function test_TransferFrom_NotBlacklisted() public {
        vm.expectEmit();
        emit Transfer(alice, bob, 10 ether);
        vm.prank(bob);
        st.transferFrom(alice, bob, 10 ether);

        vm.expectEmit();
        emit Transfer(bob, alice, 25 ether);
        vm.prank(alice);
        st.transferFrom(bob, alice, 25 ether);
    }

    function test_TransferFrom_ToBlacklisted() public whenBlacklisted(bob) {
        vm.expectRevert(abi.encodeWithSelector(AccountBlacklisted.selector, bob));
        vm.prank(bob);
        st.transferFrom(alice, bob, 10 ether);
    }

    function test_TransferFrom_FromBlacklisted() public whenBlacklisted(alice) {
        vm.expectRevert(abi.encodeWithSelector(AccountBlacklisted.selector, alice));
        vm.prank(alice);
        st.transferFrom(bob, alice, 25 ether);
    }
}
