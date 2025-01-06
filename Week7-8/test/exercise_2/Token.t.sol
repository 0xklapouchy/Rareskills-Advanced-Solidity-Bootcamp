// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "../../src/exercise_2/Token.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0 --always-install
///      echidna test/exercise_2/Token.t.sol --contract TestToken
///      ```
contract TestToken is Token {

    constructor() {
        pause(); // pause the contract
        owner = address(0); // lose ownership
    }

    function echidna_cannot_be_unpause() public view returns (bool) {
        return paused() == true;
    }
}