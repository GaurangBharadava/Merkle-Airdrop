// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GBToken} from "../src/GBToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    GBToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public gasPayer;
    address user;
    uint256 userPrevKey;

    uint256 public AMOUNT = 25 * 1e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proofOne, proofTwo];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        } else {
            token = new GBToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_MINT);
            token.transfer(address(airdrop), AMOUNT_TO_MINT);
        }
        (user, userPrevKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        // console.log("user address: %s",user);
        uint256 startingUserBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT);

        // generate the V,R,S from cheatcode vm.sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrevKey, digest);

        vm.prank(gasPayer);
        //gas payer calls claim using the signed message.
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);

        uint256 endingUserBalance = token.balanceOf(user);

        console.log("Ending Balance:", endingUserBalance);
        console.log("Starting Balance:", startingUserBalance);

        assertEq(endingUserBalance - startingUserBalance, AMOUNT);
    }
}
