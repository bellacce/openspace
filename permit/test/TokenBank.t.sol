// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/TokenERC2612.sol";
import "../src/SigUtils.sol";
import "../src/TokenBank.sol";

contract TokenBankTest is Test {
    TokenERC2612 internal tokenERC2612;
    TokenBank internal tokenBank;
    SigUtils internal sigUtils;

    uint256 internal _ownerPrivateKey;

    address internal _owner;

    function setUp() public {
        tokenERC2612 = new TokenERC2612("WOENA", "ENA");
        tokenBank = new TokenBank();

        //创造两个账户
        (address owner, uint256 ownerPrivateKey) = makeAddrAndKey("owner");

        _owner = owner;

        _ownerPrivateKey = ownerPrivateKey;

        //默认分配100个币给owner
        tokenERC2612.transfer(_owner, 100 * 10 ** 18);
    }

    function test_permitDeposit() public {
        sigUtils = new SigUtils(tokenERC2612.DOMAIN_SEPARATOR());

        vm.startPrank(_owner);
        //_owner授权tokenBank进行转账
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: _owner,
            spender: address(tokenBank),
            value: 1e18,
            nonce: tokenERC2612.nonces(_owner),
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_ownerPrivateKey, digest);

        tokenBank.permitDeposit(address(tokenERC2612), permit.value, permit.deadline, v, r, s);

        assertEq(tokenERC2612.balanceOf(_owner), 99 * 10 ** 18);
        assertEq(tokenBank.balanceOf(_owner), 1e18);
    }
}
