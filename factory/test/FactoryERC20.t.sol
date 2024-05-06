// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ContractFactory} from "../src/ContractFactory.sol";
import {RuneERC20} from "../src/RuneERC20.sol";

contract FactoryERC20Test is Test {
    ContractFactory internal contractFactory;

    //账户：项目方地址
    address public projAddr;
    //账户：发行商地址
    address public upAddr;

    //1.初始化项目方
    function setUp() public {
        projAddr = makeAddr("projAddr");
        vm.prank(projAddr);
        contractFactory = new ContractFactory();
    }

    function test_deployInscription() public {
        //2.发行商部署代币
        vm.startPrank(upAddr);
        address coinAddr = createCoin01();

        //生成测试用户
        address a = makeAddr("a");
        address b = makeAddr("b");

        // 向用户发送 1 ether 的以太币
        vm.deal(a, 1 ether);
        vm.deal(b, 1 ether);

        //3.玩家开始挖币
        vm.startPrank(a);
        contractFactory.mintInscription{value: 100000 wei}(coinAddr);

        console.log("projAddr balance: ", projAddr.balance);
        vm.stopPrank();

        vm.startPrank(b);
        contractFactory.mintInscription{value: 100000 wei}(coinAddr);
        vm.stopPrank();

        console.log("projAddr balance: ", projAddr.balance);
        console.log("upAddr balance: ", upAddr.balance);

        //4.验证项目方和发行商的余额
        assertEq(projAddr.balance, 40000);
        assertEq(upAddr.balance, 160000);
    }

    function createCoin01() internal returns (address addr) {
        string memory symbol = "coin01";
        uint256 totalSupply = 10000 * 10 ** 18;
        uint256 perMint = 2 * 10 ** 18;
        uint256 price = 1000 wei;
        return contractFactory.deployInscription(symbol, totalSupply, perMint, price);
    }
}
