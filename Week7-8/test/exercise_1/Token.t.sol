// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "../../src/exercise_1/Token.sol";

/// @dev Run the template with
///      ```
///      echidna test/exercise_1/Token.t.sol --contract TestToken
///      ```
contract TestToken is Token {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[echidna] <= 10000;
    }
}