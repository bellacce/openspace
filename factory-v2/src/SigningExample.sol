// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SigningExample {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public systemAddress;

    function setSystemAddress(address _address) public {
        systemAddress = _address;
    }

    function purchase(uint256 _amount, string calldata _nonce, bytes calldata _signature) external payable {
        require(
            isValidSignature(systemAddress, keccak256(abi.encodePacked(msg.sender, _amount, _nonce)), _signature),
            "Invalid Signature"
        );

        // mint tokens
    }

    function isValidSignature(address _systemAddress, bytes32 hash, bytes memory signature)
        internal
        pure
        returns (bool)
    {
        require(_systemAddress != address(0), "Missing System Address");

        bytes32 signedHash = hash.toEthSignedMessageHash();
        return signedHash.recover(signature) == _systemAddress;
    }
}
