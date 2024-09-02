// SPDX-License-Identifier: MIT

import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.26;

contract SanctionedToken is ERC20, Ownable2Step {
    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error AccountBlacklisted(address account);

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event Blacklisted(address indexed account, bool isBlacklisted);

    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    mapping(address => bool) public blacklisted;

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor() ERC20("Sanctioned Token", "SCT") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**18);
    }

    // -----------------------------------------------------------------------
    // Owner functions
    // -----------------------------------------------------------------------

    function setBlacklisted(address account, bool isBlacklisted) external onlyOwner() {
        blacklisted[account] = isBlacklisted;
        emit Blacklisted(account, isBlacklisted);
    }

    // -----------------------------------------------------------------------
    // Internal functions
    // -----------------------------------------------------------------------

    function _update(address from, address to, uint256 value) internal override {
        if (blacklisted[from]) {
            revert AccountBlacklisted(from);
        } else if (blacklisted[to]) {
            revert AccountBlacklisted(to);
        }

        super._update(from, to, value);
    }
}
