// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import {ProxyOpt2} from "../src/ProxyOpt2.sol";
import {NFTToken} from "../src/NFTToken.sol";
import {NFTMarketV1} from "../src/NFTMarketV1.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {TokenERC2612} from "../src/TokenERC2612.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Options} from "openzeppelin-foundry-upgrades/Options.sol";

contract ProxyUseTest is Test {
    NFTToken token;
    TokenERC2612 nftPermit;

    function setUp() public {
        // 部署721
        token = new NFTToken("MyToken", "MT");
        // 部署20
        nftPermit = new TokenERC2612("MyNFT", "MNFT");
    }
    // 部署合约时会调用run()函数

    function test_deployProxy() public {
        address a = makeAddr("a");
        vm.startPrank(a);

        Options memory opts;
        opts.unsafeSkipAllChecks = true; // 设置跳过所有检查
        // 部署代理合约与实现合约v1版本
        address proxy = Upgrades.deployTransparentProxy(
            "NFTMarketV1.sol:NFTMarketV1", a, abi.encodeCall(NFTMarketV1.initialize, (address(token)))
        );

        // 升级实现合约至v2版本
        Upgrades.upgradeProxy(proxy, "NFTMarketV2.sol:NFTMarketV2", "");
        vm.stopPrank();
        console.log("nftPermit deployed on %s", address(nftPermit));
    }
}
