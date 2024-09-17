// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is Ownable, ERC20("RewardToken", "RT") {
    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor() Ownable(msg.sender) {}

    // -----------------------------------------------------------------------
    // Owner functions
    // -----------------------------------------------------------------------

    function mint(address to, uint256 _amount) external onlyOwner {
        _mint(to, _amount);
    }
}