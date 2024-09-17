// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import { RewardToken } from "./RewardToken.sol";

contract NFTStaking is Ownable2Step, IERC721Receiver {
    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error NothingStaked();
    error NotOwner();
    error WrongNFTContract();

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------

    event Claimed(address indexed user, uint256 amount);
    event StakeAdded(address indexed user, uint256 tokenId);
    event StakeRemoved(address indexed user, uint256 tokenId);

    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    address public immutable nft;
    address public immutable rewardToken;

    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    struct Stake {
        uint256 tokens; // total NFTs staked by user
        uint256 rewardPerTokenPaid; // user accumulated per token rewards
        uint256 rewards; // current not-claimed rewards from last update
    }

    mapping(address => Stake) public tokenStake;
    mapping(uint256 => address) public nftOwner;

    // -----------------------------------------------------------------------
    // Modifiers
    // -----------------------------------------------------------------------

    modifier updateReward(address account) {
        _updateReward(account);
        _;
    }

    modifier hasStake() {
        require(tokenStake[msg.sender].tokens > 0, NothingStaked());
        _;
    }

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor(address nft_) Ownable(msg.sender) {
        nft = nft_;
        rewardToken = address(new RewardToken());
    }

    // -----------------------------------------------------------------------
    // Public functions
    // -----------------------------------------------------------------------

    function claim() external hasStake updateReward(msg.sender) {
        uint256 rewards = tokenStake[msg.sender].rewards;

        if (rewards > 0) {
            delete tokenStake[msg.sender].rewards;
            emit Claimed(msg.sender, rewards);

            RewardToken(rewardToken).mint(msg.sender, rewards);
        }
    }

    function unstake(uint256 tokenId) external hasStake updateReward(msg.sender) {
        require(nftOwner[tokenId] == msg.sender, NotOwner());

        delete nftOwner[tokenId];
        tokenStake[msg.sender].tokens--;
        emit StakeRemoved(msg.sender, tokenId);

        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        require(msg.sender == nft, WrongNFTContract());
        _addStake(from, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    function claimable(address account) external view returns (uint256) {
        return _earned(account);
    }

    // -----------------------------------------------------------------------
    // Owner actions
    // -----------------------------------------------------------------------

    function notifyRewardRate(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    // -----------------------------------------------------------------------
    // Internal functions
    // -----------------------------------------------------------------------

    function _currentRewardPerTokenStored() internal view returns (uint256) {
        uint256 timeDelta = block.timestamp - lastUpdateTime;
        uint256 unitsToDistributePerToken = rewardRate * timeDelta;

        return (rewardPerTokenStored + unitsToDistributePerToken);
    }

    function _updateReward(address account) internal {
        uint256 newRewardPerTokenStored = _currentRewardPerTokenStored();

        // if statement protects against initialization case
        if (newRewardPerTokenStored > 0) {
            rewardPerTokenStored = newRewardPerTokenStored;
            lastUpdateTime = block.timestamp;

            // setting of personal vars based on new globals
            if (account != address(0)) {
                Stake storage s = tokenStake[account];
                s.rewards = _earned(account);
                s.rewardPerTokenPaid = newRewardPerTokenStored;
            }
        }
    }

    function _addStake(address account, uint256 tokenId) internal updateReward(account) {
        tokenStake[account].tokens++;
        nftOwner[tokenId] = account;
        emit StakeAdded(account, tokenId);
    }

    function _earned(address account) internal view returns (uint256) {
        Stake memory ts = tokenStake[account];
        if (ts.tokens == 0) return ts.rewards;

        // current rate per token - rate user previously received
        uint256 userRewardDelta = _currentRewardPerTokenStored() - ts.rewardPerTokenPaid;
        uint256 userNewReward = ts.tokens * userRewardDelta;

        // add to previous rewards
        return (ts.rewards + userNewReward);
    }
}