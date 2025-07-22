// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Merkel signatue airdrop
 * @author mds
 *
 * Original Work by:
 * @author cyfrin-updraft
 * @notice https://updraft.cyfrin.io/courses/advanced-foundry/merkle-airdrop/signature-standards
 */
contract MerkleAirdrop is EIP712 {
    /*access to safe transfer*/
    using SafeERC20 for IERC20;
    // some list of addresses
    // Allow someone in the list to claim ERC-20 tokens
    // Adobtable to every erc20 token to use

    /*---ERORRS---*/
    error MerkleAirDrop__InvalidProof();
    error MerkleAirDrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /*---STATE VARIABLES---*/
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    address[] claimers;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    /*---EVENTS---*/
    event Claim(address account, uint256 amount);

    constructor(bytes32 merkleRoot, address airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = IERC20(airdropToken);
    }

    /*---EXTERNAL FUNCTIONS---*/

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        // calculate using the account and the amount , the -> the leaf node
        //proof transfer check
        if (s_hasClaimed[account]) revert MerkleAirDrop__AlreadyClaimed();
        // if the signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) revert MerkleAirDrop__InvalidProof();
        // interactions
        s_hasClaimed[account] = true;
        // actions
        i_airdropToken.safeTransfer(account, amount);

        emit Claim(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /*---GETTERS FUNCTIONS---*/

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropTokenAddress() external view returns (address) {
        return address(i_airdropToken);
    }

    function getUserClaimingStatus(address user) external view returns (bool) {
        return s_hasClaimed[user];
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
