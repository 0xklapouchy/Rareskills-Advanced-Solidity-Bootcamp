// SPDX-License-Identifier: MIT

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity 0.8.26;

contract UntrustedEscrow {
    // -----------------------------------------------------------------------
    // Lib usage
    // -----------------------------------------------------------------------

    using SafeERC20 for IERC20;

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error AlreadyEscrowed();
    error FeeOnTransferNotSupported();
    error EscrowNotMatured();

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event EscrowCreated(address indexed token, address indexed seller, address indexed buyer, uint256 amount, uint256 depositTimestamp);
    event EscrowWithdrawn(address indexed token, address indexed seller, address indexed buyer, uint256 amount);

    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    uint256 public constant DURATION = 3 days;

    struct Escrow {
        address token;
        address buyer;
        address seller;
        uint256 amount;
        uint256 depositTimestamp;
    }

    mapping(address token => mapping(address buyer => mapping(address seller => Escrow))) public escrows;

    // -----------------------------------------------------------------------
    // Public functions
    // -----------------------------------------------------------------------

    function createEscrow(address token, address seller, uint256 amount) external {
        if (escrows[token][msg.sender][seller].depositTimestamp > 0) {
            revert AlreadyEscrowed();
        }

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));

        if (balanceAfter - balanceBefore != amount) {
            revert FeeOnTransferNotSupported();
        }

        escrows[token][msg.sender][seller] = Escrow(token, msg.sender, seller, amount, block.timestamp);
        emit EscrowCreated(token, msg.sender, seller, amount, block.timestamp);
    }

    function withdrawEscrow(address token, address buyer) external {
        Escrow memory escrow = escrows[token][buyer][msg.sender];

        if (escrow.depositTimestamp == 0 || escrow.depositTimestamp + DURATION > block.timestamp) {
            revert EscrowNotMatured();
        }

        delete escrows[token][buyer][msg.sender];
        emit EscrowWithdrawn(token, buyer, msg.sender, escrow.amount);

        if (escrow.amount > 0) {
            IERC20(token).safeTransfer(msg.sender, escrow.amount);
        }
    }
}
