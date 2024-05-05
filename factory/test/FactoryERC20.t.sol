// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ContractFactory} from "../src/ContractFactory.sol";
import {RuneERC20} from "../src/RuneERC20.sol";

contract FactoryERC20Test is Test {
    ContractFactory internal contractFactory;

    function setUp() public {
        contractFactory = new ContractFactory();
    }

    function test_deployInscription() public {
        address owner = makeAddr("owner");
        vm.startPrank(owner);
        address coinAddr = createCoin01();

        // console.log("coinAddr totalSupply: ",  RuneERC20(coinAddr).totalSupply());

        //生成测试用户
        address a = makeAddr("a");
        address b = makeAddr("b");
        // RuneERC20(coinAddr).transfer(a, 10 ** 18);
        // RuneERC20(coinAddr).transfer(b, 10 ** 18);

        vm.stopPrank();

        // 向用户发送 1 ether 的以太币
        vm.deal(a, 1 ether);
        vm.deal(b, 1 ether);
        //  deal(address(dai), alice, 1001 ether);

        vm.startPrank(a);
        //value == msg.value
        contractFactory.mintInscription{value: 1 ether}(coinAddr);
        assertEq(RuneERC20(coinAddr).balancesAddr(a), 2 * 10 ** 18);
        vm.stopPrank();

        vm.startPrank(b);
        contractFactory.mintInscription{value: 1 ether}(coinAddr);
        assertEq(RuneERC20(coinAddr).balancesAddr(b), 2 * 10 ** 18);
        vm.stopPrank();

        console.log("finished totalSupply: ", RuneERC20(coinAddr).totalSupply());
        assertEq(RuneERC20(coinAddr).totalSupply(), 4 * 10 ** 18);
    }

    function createCoin01() internal returns (address addr) {
        string memory symbol = "coin01";
        uint256 totalSupply = 10000 * 10 ** 18;
        uint256 perMint = 2 * 10 ** 18;
        uint256 price = 1;
        return contractFactory.deployInscription(symbol, totalSupply, perMint, price);
    }
}
