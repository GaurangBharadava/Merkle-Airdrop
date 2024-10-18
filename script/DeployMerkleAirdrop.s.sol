// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {GBToken} from "../src/GBToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
contract DeployMerkleAirdrop is Script {
    MerkleAirdrop airdrop;
    GBToken token;

    bytes32 public s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_TRANSFER = 4 * 25 * 1e18;
    function run() external returns(MerkleAirdrop, GBToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns(MerkleAirdrop, GBToken) {
        vm.startBroadcast();
        token = new GBToken();
        airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(),AMOUNT_TO_TRANSFER);
        token.transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();

        return(airdrop, token);
    }
}