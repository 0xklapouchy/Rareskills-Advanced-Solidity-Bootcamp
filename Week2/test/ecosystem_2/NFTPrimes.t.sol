// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import { Test, console } from "forge-std/Test.sol";
import { NFTEnumerable } from "../../src/ecosystem_2/NFTEnumerable.sol";
import { NFTPrimes } from "../../src/ecosystem_2/NFTPrimes.sol";

contract NFTEnumerableTest is Test {
    NFTPrimes nftPrimes;
    NFTEnumerable nft;
    address owner;
    address alice;
    address bob;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        nft = new NFTEnumerable();
        nftPrimes = new NFTPrimes(address(nft));

        for (uint256 i = 0; i < 27; i++) {
            nft.mint(alice);
        }

        for (uint256 i = 27; i < 61; i++) {
            nft.mint(bob);
        }
    }

    function test_Deploy() public view {
        assertEq(address(nftPrimes.nftEnumerable()), address(nft));
    }

    function test_isPrime() public view {
        assertEq(nftPrimes.isPrime(1), false);
        assertEq(nftPrimes.isPrime(2), true);
        assertEq(nftPrimes.isPrime(3), true);   
        assertEq(nftPrimes.isPrime(4), false);
        assertEq(nftPrimes.isPrime(5), true);
        assertEq(nftPrimes.isPrime(6), false);
        assertEq(nftPrimes.isPrime(7), true);
        assertEq(nftPrimes.isPrime(8), false);
        assertEq(nftPrimes.isPrime(9), false);
        assertEq(nftPrimes.isPrime(10), false);
        assertEq(nftPrimes.isPrime(11), true);
        assertEq(nftPrimes.isPrime(12), false);
        assertEq(nftPrimes.isPrime(13), true);
        assertEq(nftPrimes.isPrime(14), false);
        assertEq(nftPrimes.isPrime(15), false);
        assertEq(nftPrimes.isPrime(16), false);
        assertEq(nftPrimes.isPrime(17), true);
        assertEq(nftPrimes.isPrime(18), false);
        assertEq(nftPrimes.isPrime(19), true);
        assertEq(nftPrimes.isPrime(20), false);
        assertEq(nftPrimes.isPrime(47), true);
        assertEq(nftPrimes.isPrime(48), false);
        assertEq(nftPrimes.isPrime(49), false);
        assertEq(nftPrimes.isPrime(50), false);
        assertEq(nftPrimes.isPrime(51), false);
        assertEq(nftPrimes.isPrime(52), false);
        assertEq(nftPrimes.isPrime(53), true);
        assertEq(nftPrimes.isPrime(221), false);
        assertEq(nftPrimes.isPrime(222), false);
        assertEq(nftPrimes.isPrime(223), true);
        assertEq(nftPrimes.isPrime(513), false);
        assertEq(nftPrimes.isPrime(514), false);
        assertEq(nftPrimes.isPrime(515), false);
        assertEq(nftPrimes.isPrime(516), false);
        assertEq(nftPrimes.isPrime(517), false);
        assertEq(nftPrimes.isPrime(518), false);
        assertEq(nftPrimes.isPrime(519), false);
        assertEq(nftPrimes.isPrime(520), false);
        assertEq(nftPrimes.isPrime(521), true);
    }

    function test_getPrimesCount() public {
        assertEq(nftPrimes.getPrimesCount(alice), 9);
        assertEq(nftPrimes.getPrimesCount(bob), 9);

        for (uint256 i = 61; i < 81; i++) {
            nft.mint(alice);
        }

        for (uint256 i = 81; i < 100; i++) {
            nft.mint(bob);
        }

        assertEq(nftPrimes.getPrimesCount(alice), 13);
        assertEq(nftPrimes.getPrimesCount(bob), 12);
    }
}
