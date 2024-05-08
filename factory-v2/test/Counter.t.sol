// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    event LogData(bytes32 data);

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);

        bytes32 data = keccak256(abi.encode(1));
        //console.log("projAddr balance: ");
        emit LogData(data);
        bytes32 data1 = keccak256(abi.encode(2));
        emit LogData(data1);

        data1 = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        emit LogData(data1);

        data1 = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
        emit LogData(data1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
