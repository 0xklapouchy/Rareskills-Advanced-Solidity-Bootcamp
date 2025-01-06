// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "../../src/exercise_3/MintableToken.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0 --always-install
///      echidna test/exercise_3/Token.t.sol --contract TestToken
///      ```
contract TestToken is MintableToken {
    address echidna = msg.sender;

    constructor() MintableToken(10000) {
        owner = echidna;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[msg.sender] <= 10_000;
    }
}