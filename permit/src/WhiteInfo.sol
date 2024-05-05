// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "./SigUtils.sol";
import "./TokenERC2612.sol";

contract WhiteInfo {
    address public owner;
    SigUtils public sigUtils;
    uint256 public nonce;
    TokenERC2612 internal tokenERC2612;

    struct SignInfo {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    mapping(address => SignInfo) public whitelist;

    constructor() {
        owner = msg.sender;
        nonce = 0;
        sigUtils = new SigUtils(tokenERC2612.DOMAIN_SEPARATOR());
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 添加地址到白名单
    function addToWhitelist(address _address, uint8 v, bytes32 r, bytes32 s) public onlyOwner {
        SignInfo memory newSignInfo = SignInfo(v, r, s);
        whitelist[_address] = newSignInfo;
    }

    // 从白名单中移除地址
    function removeFromWhitelist(address addr) public onlyOwner {
        delete whitelist[addr];
    }

    // 检查地址是否在白名单中
    function isWhitelisted(address addr) public view returns (bool) {
        return whitelist[addr].v == 0 && whitelist[addr].r == 0 && whitelist[addr].s == 0;
    }
}
