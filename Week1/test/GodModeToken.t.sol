// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { GodModeToken } from "../src/GodModeToken.sol";
import { IERC20Errors } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GodModeTokenTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    GodModeToken public st;
    address owner;
    address alice;
    address bob;

    function setUp() public {
        st = new GodModeToken();
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        st.transfer(alice, 100 ether);
        st.transfer(bob, 100 ether);

        vm.prank(alice);
        st.approve(bob, 10 ether);
    }

    function test_TransferFrom_Normal_Cant_Mint() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, alice, 0 , 10 ether));
        vm.prank(alice);
        st.transferFrom(address(0), alice, 10 ether);
    }

    function test_TransferFrom_Normal_Cant_Burn() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        vm.prank(bob);
        st.transferFrom(alice, address(0), 10 ether);
    }

    function test_TransferFrom_Normal_Cant_Transfer_Without_Allowance() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, alice, 0, 10 ether));
        vm.prank(alice);
        st.transferFrom(bob, alice, 10 ether);
    }

    function test_TransferFrom_Normal_Can_Transfer_With_Allowance() public {
        vm.expectEmit();
        emit Transfer(alice, bob, 10 ether);
        vm.prank(bob);
        st.transferFrom(alice, bob, 10 ether);
    }

    function test_TransferFrom_GodMode_Can_Mint() public {
        vm.expectEmit();
        emit Transfer(address(0), alice, 10 ether);
        st.transferFrom(address(0), alice, 10 ether);
    }

    function test_TransferFrom_GodMode_Can_Burn() public {
        vm.expectEmit();
        emit Transfer(alice, address(0), 10 ether);
        st.transferFrom(alice, address(0), 10 ether);
    }

    function test_TransferFrom_GodMode_Cant_Burn_MoreThan_Balance() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 100 ether, 200 ether));
        st.transferFrom(alice, address(0), 200 ether);
    }

    function test_TransferFrom_GodMode_Can_Transfer_Between_Account() public {
        vm.expectEmit();
        emit Transfer(alice, bob, 10 ether);
        st.transferFrom(alice, bob, 10 ether);

        vm.expectEmit();
        emit Transfer(bob, alice, 25 ether);
        st.transferFrom(bob, alice, 25 ether);
    }

    function test_TransferFrom_GodMode_Cant_Transfer_Between_Account_If_MoreThan_Balance() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 100 ether, 200 ether));
        st.transferFrom(alice, bob, 200 ether);

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, bob, 100 ether, 150 ether));
        st.transferFrom(bob, alice, 150 ether);
    }
}
