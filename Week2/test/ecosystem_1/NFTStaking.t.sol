// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.27;

import { Test, console } from "forge-std/Test.sol";
import { NFTStaking } from "../../src/ecosystem_1/NFTStaking.sol";
import { NFTWithDiscount } from "../../src/ecosystem_1/NFTWithDiscount.sol";
import { RewardToken } from "../../src/ecosystem_1/RewardToken.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStakingTest is Test {
    NFTStaking public staking;
    address owner;
    address alice;
    address bob;

    NFTWithDiscount nft;
    RewardToken rewardToken;
    bytes32[] public merkleTree;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice"); // 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6
        bob = makeAddr("bob"); // 0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e

        /// tree with 4 leaves and 3 levels
        merkleTree = new bytes32[](7);
        uint256 index = 0;
        merkleTree[6] = keccak256(bytes.concat(keccak256(abi.encode(alice, ++index))));
        merkleTree[5] = keccak256(bytes.concat(keccak256(abi.encode(bob, ++index))));
        merkleTree[4] = keccak256(bytes.concat(keccak256(abi.encode(alice, ++index))));
        merkleTree[3] = keccak256(bytes.concat(keccak256(abi.encode(bob, ++index))));
        merkleTree[2] = (merkleTree[5] > merkleTree[6]) ? keccak256(abi.encode(merkleTree[6], merkleTree[5])) : keccak256(abi.encode(merkleTree[5], merkleTree[6]));
        merkleTree[1] = (merkleTree[3] > merkleTree[4]) ? keccak256(abi.encode(merkleTree[4], merkleTree[3])) : keccak256(abi.encode(merkleTree[3], merkleTree[4]));
        merkleTree[0] = (merkleTree[1] > merkleTree[2]) ? keccak256(abi.encode(merkleTree[2], merkleTree[1])) : keccak256(abi.encode(merkleTree[1], merkleTree[2]));

        nft = new NFTWithDiscount(merkleTree[0]);
        staking = new NFTStaking(address(nft));
        rewardToken = RewardToken(staking.rewardToken());

        nft.mint{value: 0.1 ether}(alice);
        nft.mint{value: 0.1 ether}(alice);
        nft.mint{value: 0.1 ether}(bob);
    }

    function test_Deploy() public {
        assertEq(staking.owner(), address(this));
        assertEq(rewardToken.owner(), address(staking));
        assertEq(rewardToken.totalSupply(), 0);
    }

    function test_onERC721Received_Will_Revert_If_Not_NFT() public {
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.WrongNFTContract.selector));
        staking.onERC721Received(address(0), address(0), 0, "");
    }

    function test_notifyRewardRate_No_Rewards_Before_Initialization() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);

        uint256 claimable = staking.claimable(alice);
        assertEq(claimable, 0);

        vm.warp(1 days);

        claimable = staking.claimable(alice);
        assertEq(claimable, 0);
    }

    function test_notifyRewardRate_Rewards_Accumulates_After_Initialization() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);

        uint256 claimable = staking.claimable(alice);
        assertEq(claimable, 0);

        staking.notifyRewardRate(11574074074075); // >= 1e18 / 86400
        vm.warp(1 days + 1);

        claimable = staking.claimable(alice);
        assertGe(claimable, 1e18);
    }

    function test_Claim_Reverts_If_Nothing_Staked() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NothingStaked.selector));
        staking.claim();
    }

    function test_Claim_Will_Claim_Nothing_If_No_Rewards() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);

        vm.warp(1 days + 1);

        vm.prank(alice);
        staking.claim();
        
        assertEq(rewardToken.balanceOf(alice), 0);
    }

    function test_Claim_Will_Claim_Rewards() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);

        staking.notifyRewardRate(11574074074075); // >= 1e18 / 86400
        vm.warp(1 days + 1);

        vm.prank(alice);
        staking.claim();
        
        assertGe(rewardToken.balanceOf(alice), 1e18);
    }

    function test_Unstake_Will_Revert_If_Nothing_Staked() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NothingStaked.selector));
        staking.unstake(1);
    }

    function test_Unstake_Will_Revert_If_Unstakeing_Incorrect_Token() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 3);
        
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NotOwner.selector));
        staking.unstake(2);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(NFTStaking.NotOwner.selector));
        staking.unstake(3);
    }

    function test_Unstake_Should_Unstake_Correctly() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(staking), 1);
        vm.prank(bob);
        nft.safeTransferFrom(bob, address(staking), 3);

        NFTStaking.Stake memory stake;

        vm.prank(alice);
        staking.unstake(1);
        assertEq(nft.ownerOf(1), alice);

        (stake.tokens, ,) = staking.tokenStake(alice);
        assertEq(stake.tokens, 0);

        vm.prank(bob);
        staking.unstake(3);
        assertEq(nft.ownerOf(3), bob);

        (stake.tokens, ,) = staking.tokenStake(bob);
        assertEq(stake.tokens, 0);
    }
}
