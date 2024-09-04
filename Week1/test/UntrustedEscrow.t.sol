// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { UntrustedEscrow } from "../src/UntrustedEscrow.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow public ue;
    address alice;
    address bob;

    ERC20 standard;
    ERC20 fee;

    struct Escrow {
        address token;
        address buyer;
        address seller;
        uint256 amount;
        uint256 depositTimestamp;
    }

    function setUp() public {
        ue = new UntrustedEscrow();

        standard = new ERC20Mock();
        fee = new ERC20FeeMock();

        alice = makeAddr("alice");
        bob = makeAddr("bob");

        standard.approve(address(ue), 100 ether);
        fee.approve(address(ue), 100 ether);

        vm.warp(1725443736);
    }

    function test_createEscrow_Will_Revert_On_Already_Escrowed() public {
        ue.createEscrow(address(standard), alice, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.AlreadyEscrowed.selector));
        ue.createEscrow(address(standard), alice, 1 ether);
    }

    function test_createEscrow_Will_Revert_With_FeeOnTransfer() public {
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.FeeOnTransferNotSupported.selector));
        ue.createEscrow(address(fee), alice, 1 ether);
    }

    function test_createEscrow_Should_Create_Escrow() public {
        ue.createEscrow(address(standard), alice, 1 ether);
        
        Escrow memory escrow;
        (escrow.token, escrow.buyer, escrow.seller, escrow.amount, escrow.depositTimestamp) = ue.escrows(address(standard), address(this), alice);
        
        assertEq(escrow.token, address(standard));
        assertEq(escrow.buyer, address(this));
        assertEq(escrow.seller, alice);
        assertEq(escrow.amount, 1 ether);
        assertEq(escrow.depositTimestamp, block.timestamp);
    }

    function test_withdrawEscrow_Will_Revert_On_Escrow_Not_Matured() public {
        ue.createEscrow(address(standard), alice, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.EscrowNotMatured.selector));
        vm.prank(alice);
        ue.withdrawEscrow(address(standard), address(this));
    }

    function test_withdrawEscrow_Will_Revert_On_Empty_Escrow() public {
        vm.expectRevert(abi.encodeWithSelector(UntrustedEscrow.EscrowNotMatured.selector));
        vm.prank(alice);
        ue.withdrawEscrow(address(standard), address(this));
    }

    function test_withdrawEscrow_Should_Withdraw_Escrow() public {
        ue.createEscrow(address(standard), alice, 1 ether);
        vm.warp(block.timestamp + 4 days);
        vm.prank(alice);
        ue.withdrawEscrow(address(standard), address(this));
        assertEq(standard.balanceOf(alice), 1 ether);
    }
}

contract ERC20Mock is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 100_000 * 10**18);
    }
}


contract ERC20FeeMock is ERC20 {
    constructor() ERC20("FeeMock", "FEE") {
        _mint(msg.sender, 100_000 * 10**18);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from == address(0) || to == address(0)) {
            super._update(from, to, value);
            return;
        }

        uint256 fee = value * 500 / 10000; // 5% fee
        super._update(from, address(this), fee);
        super._update(from, to, value - fee);
    }
}