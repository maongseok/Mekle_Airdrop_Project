// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {Deployer} from "script/Deployer.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;

    address user;
    uint256 userPrivKey;
    address gasPayer;
    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1, proof2];

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    // function setUp() public {
    //     if (isZkSyncChain()) {
    //         token = new BagelToken();
    //         airdrop = new MerkleAirdrop(ROOT, token);
    //         token.mint(address(airdrop), AMOUNT_TO_SEND);
    //         console.log("user  address:", user);
    //     } else {
    //         Deployer deployer = new Deployer();
    //         (airdrop, token) = deployer.run();
    //     }
    //     (user, userPrivKey) = makeAddrAndKey("user");
    //     gasPayer = makeAddr("gasPayer");
    // }
    function setUp() public {
        if (!isZkSyncChain()) {
            Deployer deployer = new Deployer();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, address(token));
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        gasPayer = makeAddr("gasPayer");
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        //revise

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        //make
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance:", endingBalance);
        assertEq(endingBalance + startingBalance, AMOUNT_TO_CLAIM);
    }
}
