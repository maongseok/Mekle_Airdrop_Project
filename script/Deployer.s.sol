// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Deployer is Script {
    bytes32 private s_merkleRoot = 0x67ff2810c6ff1a2dec2da5ab404b4fb6c8ffdecb64cb920c539d234a786caab6;
    uint256 private s_amountToTransfer = (25e18) * 4;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, token);
        token.mint(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() public returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
