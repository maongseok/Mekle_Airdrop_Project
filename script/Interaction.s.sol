// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract Interaction is Script {
    error Interaction__invalidSigLength();
    // allows one account (the transaction sender) to claim an airdrop on behalf of another
    // 1.User Authorization
    // 2. Third-party claim

    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 proof1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1, proof2];
    bytes private SIGNATURE =
        hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    /* --- User --- */
    address user;
    uint256 userPriKey;
    bytes32 proofUser1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofUser2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public userPROOF = [proofUser1, proofUser2];

    function run() external {
        address airdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(airdrop);
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        // because length is 32 + 32+ 1
        if (sig.length != 65) revert Interaction__invalidSigLength();
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function claimUserAirdrop() external {
        (user, userPriKey) = makeAddrAndKey("user");
        address airdrop = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);

        bytes32 digest = MerkleAirdrop(airdrop).getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPriKey, digest);

        vm.startBroadcast();
        MerkleAirdrop(airdrop).claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopBroadcast();
    }
}
