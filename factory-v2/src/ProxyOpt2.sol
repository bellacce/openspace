// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

//操作升级合约
contract ProxyOpt2 is Ownable {
    address public transparentProxy;

    constructor() Ownable(msg.sender) {
        Options memory opts;
        opts.unsafeSkipAllChecks = true; // 设置跳过所有检查
        // Upgrades.upgradeProxy(
        //     transparentProxy,
        //     "MyContractV2.sol",
        //     abi.encodeCall(MyContractV2.foo, ("arguments for foo"))
        // );

        bytes memory initializerData = abi.encodeWithSignature("initialize(uint8 num)", 99, opts);
        // 部署代理合约
        transparentProxy = Upgrades.deployTransparentProxy("NFTMarketV1.sol", msg.sender, initializerData);
    }

    // 使用代理升级逻辑合约
    function upgradeImplementation() external {
        bytes memory initializerData = abi.encodeWithSignature("initialize(uint8 num)", 88);
        Upgrades.upgradeProxy(transparentProxy, "NFTMarketV2.sol", initializerData);
    }
}
