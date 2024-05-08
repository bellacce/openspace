// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
// import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

// 代理合约
contract ProxyCon is TransparentUpgradeableProxy {
    constructor(address _logic, address _admin, bytes memory _data)
        payable
        TransparentUpgradeableProxy(_logic, _admin, _data)
    {}

    // function rece
}
