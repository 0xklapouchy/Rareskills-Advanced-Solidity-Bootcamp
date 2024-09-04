// SPDX-License-Identifier: MIT

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity 0.8.26;

contract BondingCurveToken is ERC20 {
    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error InvalidTokenAmount();
    error InsufficientPayment();
    error TransferFailed();
    error SlippageLimitExceeded(uint256 expected, uint256 actual);

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event TokenBought(address indexed buyer, uint256 amount, uint256 price);
    event TokenSold(address indexed seller, uint256 amount, uint256 price);

    // -----------------------------------------------------------------------
    // Immutable variables
    // -----------------------------------------------------------------------

    uint256 public immutable slope;
    uint256 public immutable intercept;

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor(uint256 slope_, uint256 intercept_) ERC20("BondingCurve Token", "BCT") {
        slope = slope_;
        intercept = intercept_;
    }

    // -----------------------------------------------------------------------
    // Public functions
    // -----------------------------------------------------------------------

    function buyTokens(uint256 amount) external payable {
        amount = amount / 1e18;

        if (amount == 0) {
            revert InvalidTokenAmount();
        }

        uint256 price = getBuyPrice(amount);
        if (msg.value < price) {
            revert InsufficientPayment();
        }

        _mint(msg.sender, amount * 1e18);
        emit TokenBought(msg.sender, amount * 1e18, price);

        uint256 refund = msg.value - price;
        if (refund > 0) {
            (bool success, ) = payable(msg.sender).call{value: refund}("");
            if (!success) {
                revert TransferFailed();
            }
        }
    }

    function sellTokens(uint256 amount, uint256 minExpected) external {
        amount = amount / 1e18;

        if (amount == 0) {
            revert InvalidTokenAmount();
        }

        uint256 price = getSellPrice(amount);
        if (price < minExpected) {
            revert SlippageLimitExceeded(minExpected, price);
        }

        _burn(msg.sender, amount * 1e18);
        emit TokenSold(msg.sender, amount * 1e18, price);

        (bool success, ) = payable(msg.sender).call{value: price}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function getBuyPrice(uint256 amount) public view returns (uint256) {
        uint256 total = totalSupply() / 1e18;
        return slope * (amount * total + (amount * (amount - 1)) / 2) + amount * intercept;
    }

    function getSellPrice(uint256 amount) public view returns (uint256) {
        uint256 total = totalSupply() / 1e18 - amount;
        return slope * (amount * total - (amount * (amount - 1)) / 2) + amount * intercept;
    }
}
