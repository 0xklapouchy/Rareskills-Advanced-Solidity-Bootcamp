// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract NFTPrimes {
    IERC721Enumerable public nftEnumerable;

    constructor(address nftEnumerable_) {
        nftEnumerable = IERC721Enumerable(nftEnumerable_);
    }

    function getPrimesCount(address owner) external view returns (uint256 primeCount) {
        uint256 total = nftEnumerable.balanceOf(owner);

        for (uint256 i = 0; i < total; i++) {
            uint256 tokenId = nftEnumerable.tokenOfOwnerByIndex(owner, i);
            if (_isPrime(tokenId)) {
                primeCount++;
            }
        }
    }

    function isPrime(uint256 num) external pure returns (bool) {
        return _isPrime(num);
    }

    function _isPrime(uint256 num) private pure returns (bool) {
        if (num <= 1) {
            return false;
        }
        if (num == 2 || num == 3) {
            return true;
        }
        if (num % 2 == 0 || num % 3 == 0) {
            return false;
        }

        // Check for factors from 5 up to sqrt(num) (6k ± 1 rule)
        for (uint256 i = 5; i * i <= num; i += 6) {
            if (num % i == 0 || num % (i + 2) == 0) {
                return false;
            }
        }

        return true;
    }
}