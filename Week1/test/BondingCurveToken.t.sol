// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { BondingCurveToken } from "../src/BondingCurveToken.sol";

contract BondingCurveTokenTest is Test {
    BondingCurveToken public bct;
    address owner;
    address alice;

    uint256 constant SLOPE = 0.5 ether;
    uint256 constant INTERCEPT = 0.1 ether;

    function setUp() public {
        bct = new BondingCurveToken(SLOPE, INTERCEPT);
        alice = makeAddr("alice");
    }

    function test_buyTokens_Will_Revert_On_Zero_Amount() public {
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.InvalidTokenAmount.selector));
        bct.buyTokens(0);
    }

    function test_buyTokens_Will_Revert_On_Insufficient_Payment() public {
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.InsufficientPayment.selector));
        bct.buyTokens{value: 0.6 ether}(2 ether);
    }

    function test_buyTokens_Can_Buy_With_Exact_Payment() public {
        vm.expectEmit();
        emit BondingCurveToken.TokenBought(address(this), 2 ether, 0.7 ether);
        bct.buyTokens{value: 0.7 ether}(2 ether);
    }

    function test_buyTokens_Can_Buy_And_Expect_Refund_When_Overpayment() public {
        vm.deal(alice, 5 ether);
        uint256 balanceBefore = alice.balance;
        vm.prank(alice);
        bct.buyTokens{value: 5 ether}(2 ether);

        assertEq(alice.balance, balanceBefore - 0.7 ether);
    }

    function test_buyTokens_Will_Truncate_To_Whole_Amounts() public {
        vm.expectEmit();
        emit BondingCurveToken.TokenBought(address(this), 2 ether, 0.7 ether);
        bct.buyTokens{value: 0.7 ether}(2.5 ether);
    }

    function test_buyTokens_Will_Revert_On_Refund_For_SC_Without_Receive() public {
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.TransferFailed.selector));
        bct.buyTokens{value: 1 ether}(1 ether);
    }

    function test_sellTokens_Will_Revert_On_Zero_Amount() public {
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.InvalidTokenAmount.selector));
        bct.sellTokens(0, 0);
    }

    function test_sellTokens_Will_Revert_On_Slippage_Limit_Exceeded() public {
        bct.buyTokens{value: 0.7 ether}(2 ether);
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.SlippageLimitExceeded.selector, 1 ether, 0.6 ether));
        bct.sellTokens(1e18, 1 ether);
    }

    function test_sellTokens_Can_Sell_Withing_Slippage_Limit() public {
        vm.deal(alice, 5 ether);
        vm.prank(alice);
        bct.buyTokens{value: 0.7 ether}(2 ether);
        vm.expectEmit();
        emit BondingCurveToken.TokenSold(alice, 1 ether, 0.6 ether);
        vm.prank(alice);
        bct.sellTokens(1e18, 0.5 ether);
    }

    function test_sellTokens_Will_Revert_When_ETH_Receive_Is_Not_Supported() public {
        bct.buyTokens{value: 0.7 ether}(2 ether);
        vm.expectRevert(abi.encodeWithSelector(BondingCurveToken.TransferFailed.selector));
        bct.sellTokens(1e18, 0.6 ether);
    }

    function test_buyPrice_Will_Return_Correct_Price() public view {
        assertEq(bct.getBuyPrice(2), 0.7 ether);
    }

    function test_sellPrice_Will_Return_Correct_Price() public {
        bct.buyTokens{value: 0.7 ether}(2 ether);
        assertEq(bct.getSellPrice(1), 0.6 ether);
    }
}
