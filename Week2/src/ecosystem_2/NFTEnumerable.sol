// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { ERC721Enumerable, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTEnumerable is ERC721Enumerable {
    error MaxSupplyReached();
    error InvalidPrice();

    constructor() ERC721("NFTEnumerable", "NFTE")  {}

    uint256 private constant MAX_SUPPLY = 100;

    function mint(address to) external payable {
        uint256 total = totalSupply();
        require(total < MAX_SUPPLY, MaxSupplyReached());

        _safeMint(to, total + 1);
    }
}