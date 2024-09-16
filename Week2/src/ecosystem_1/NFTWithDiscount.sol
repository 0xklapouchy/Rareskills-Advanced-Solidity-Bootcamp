// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ERC721Royalty, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract NFTWithDiscount is ERC721Royalty, Ownable2Step {
    // -----------------------------------------------------------------------
    // Lib usage
    // -----------------------------------------------------------------------

    using BitMaps for BitMaps.BitMap;

    // -----------------------------------------------------------------------
    // Errors
    // -----------------------------------------------------------------------

    error MaxSupplyReached();
    error InvalidPrice();
    error AlreadyDiscounted();
    error InvalidProof();
    error TransferFailed();

    // -----------------------------------------------------------------------
    // Storage variables
    // -----------------------------------------------------------------------

    uint256 private constant MAX_SUPPLY = 1000;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;
    uint256 public totalSupply;

    // -----------------------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------------------

    constructor(bytes32 merkleRoot_) ERC721("NFTWithDiscount", "NFTWD") Ownable(msg.sender) {
        merkleRoot = merkleRoot_;
        _setDefaultRoyalty(owner(), 250);
    }

    // -----------------------------------------------------------------------
    // Public functions
    // -----------------------------------------------------------------------

    function mint(address to) external payable {
        require(totalSupply < MAX_SUPPLY, MaxSupplyReached());
        require(msg.value == 0.1 ether, InvalidPrice());

        _safeMint(to, ++totalSupply);
    }

    function mintWithDiscount(address to, bytes32[] calldata proof, uint256 index) external payable {
        require(totalSupply < MAX_SUPPLY, MaxSupplyReached());
        require(!claimedBitMap.get(index), AlreadyDiscounted());
        require(msg.value == 0.01 ether, InvalidPrice());

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, index))));

        require(MerkleProof.verify(proof, merkleRoot, leaf), InvalidProof());

        claimedBitMap.set(index);

        _safeMint(to, ++totalSupply);
    }

    // -----------------------------------------------------------------------
    // Owner functions
    // -----------------------------------------------------------------------

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, TransferFailed());
    }
}