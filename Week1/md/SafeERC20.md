## SafeERC20

`SafeERC20` is a library designed to ensure safe and reliable token transfers for contracts interacting with ERC20 tokens.

#### What it solves:

1. `Non-standard ERC20 behavior`: Some tokens, like USDT, don't return a boolean if `transfer` or `transferFrom` functions. SafeERC20 wraps these functions to ensure they either revert on failure or handle the error gracefully.
2. `Preventing errors`: It prevents common issues like missed return value checks, which could lead to silent failures in token transfers.

By using `SafeERC20`, developers ensure that token interactions are consistent and secure, even with weird ERC20 tokens.