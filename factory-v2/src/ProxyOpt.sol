// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "./ProxyCon.sol";

//操作升级合约
contract ProxyUse is Ownable {
    //管理员地址
    address public proxyAdminAddress;
    //代理合约地址
    address public proxyAddress;

    // 部署合约: _implementationAddress 逻辑合约， createAddr 更换合约控制人
    constructor(address _implementationAddress, address createAddr) Ownable(createAddr) {
        // 部署代理合约
        ProxyCon proxy =
            new ProxyCon(address(_implementationAddress), createAddr, abi.encodeWithSignature("initialize()"));

        // 设置代理合约地址和管理员地址
        proxyAddress = address(proxy);
        proxyAdminAddress = createAddr;
    }

    // 使用代理升级逻辑合约
    function upgradeImplementation(address _newImplementationAddress, bytes memory _data) external payable onlyOwner {
        ProxyAdmin(msg.sender).upgradeAndCall{value: msg.value}(
            ITransparentUpgradeableProxy(proxyAddress), _newImplementationAddress, _data
        );
    }
}
