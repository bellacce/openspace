// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {ProxyOpt2} from "../src/ProxyOpt2.sol";
import {NFTToken} from "../src/NFTToken.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {TokenERC2612} from "../src/TokenERC2612.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

//forge script script/Counter.s.sol:CounterScript
// 部署脚本继承了Script合约
contract ProxyUseScript is Script {
    function setUp() public {}

    // 部署合约时会调用run()函数
    function run() public {
        //        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast();
        // 部署721
        NFTToken token = new NFTToken("MyToken", "MT");
        // 部署20
        TokenERC2612 nftPermit = new TokenERC2612("MyNFT", "MNFT");

        // 部署代理合约与实现合约v1版本
        address proxy = Upgrades.deployTransparentProxy(
            "NFTMarketV1.sol:NFTMarketV1", msg.sender, abi.encodeCall(NFTMarketV1.initialize, (address(token)))
        );

        // 升级实现合约至v2版本
        Upgrades.upgradeProxy(proxy, "NFTMarketV2.sol:NFTMarketV2", "");

        console.log("nftPermit deployed on %s", address(nftPermit));

        vm.stopBroadcast();
    }
}
