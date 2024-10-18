// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    //List of address.
    //Allow aomeone in the list to claim token.

    error MerkleAirdeop__InvalidProof();
    error MerkleAirdeop__HasClaimed();

    event Claim(address indexed accoun, uint256 indexed amount);

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airderopToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airderopToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account] == true) {
            revert MerkleAirdeop__HasClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdeop__InvalidProof();
        }

        s_hasClaimed[account] = true;
        emit Claim(account, amount);

        // i_airderopToken.transfer(account,amount);
        //we will use safe Transfer function of SafeERC20 token. that will handles revert and error for us.
        i_airderopToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airderopToken;
    }
}
