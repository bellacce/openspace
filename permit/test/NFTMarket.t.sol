// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/TokenERC2612.sol";
import "../src/SigUtils.sol";
import "../src/NFTMarket.sol";
import "../src/NFTToken.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarketTest is Test {
    TokenERC2612 internal tokenERC2612;
    SigUtils internal sigUtils;
    NFTMarket internal nFTMarket;
    NFTToken internal nFTToken;

    uint256 internal _ownerPrivateKey;
    address internal _owner;

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    function setUp() public {
        //4.创造owner系统账户
        (address owner, uint256 ownerPrivateKey) = makeAddrAndKey("owner");
        _owner = owner;
        _ownerPrivateKey = ownerPrivateKey;

        //1.初始化代币制造工厂
        tokenERC2612 = new TokenERC2612("WOENA", "ENA");

        //2.初始化nft制造工厂
        nFTToken = new NFTToken();

        vm.startPrank(_owner);
        //3.创造nft交易市场
        nFTMarket = new NFTMarket(address(tokenERC2612));
        vm.stopPrank();
    }

    function test_permitDeposit() public {
        vm.startPrank(_owner);
        //1.制作2个nft
        uint256 tokenId1 = nFTToken.mint(_owner, "wwww.a.com");
        uint256 tokenId2 = nFTToken.mint(_owner, "wwww.b.com");

        //2.nft拥有者上nft交易市场, 设置nft价格
        //授权
        nFTToken.approve(address(nFTMarket), tokenId1);
        nFTToken.approve(address(nFTMarket), tokenId2);
        //上架
        nFTMarket.list(address(nFTToken), tokenId1, 10 * 10 ** 18);
        nFTMarket.list(address(nFTToken), tokenId2, 10 * 10 ** 18);
        vm.stopPrank();

        //3.创建3个用户
        address a = makeAddr("a");
        address b = makeAddr("b");
        address c = makeAddr("c");

        //4.分配100个币给2个用户
        tokenERC2612.transfer(a, 100 * 10 ** 18);
        tokenERC2612.transfer(b, 100 * 10 ** 18);
        tokenERC2612.transfer(c, 100 * 10 ** 18);

        //5.加入2个白名单用户
        (bytes memory signA, uint256 nonceA) = signAddress(a);
        (bytes memory signB, uint256 nonceB) = signAddress(b);
        // (bytes memory signC, uint256 nonceC) = signAddress(c);
        vm.stopPrank();

        //6.添加msg.sender上下文用户
        // vm.startPrank(a);

        uint256 amount = 10 * 10 ** 18;
        vm.startPrank(a);

        //授权
        tokenERC2612.approve(address(nFTMarket), amount);
        nFTMarket.permitBuy(address(nFTToken), signA, nonceA, tokenId1, amount);
        vm.stopPrank();
        assertEq(nFTMarket.tokenHolder(tokenId1), a);

        vm.startPrank(c);
        (bool success,) = address(nFTMarket).call(
            abi.encodeWithSignature(
                " function permitBuy(address nftToken, bytes memory signature, uint256 nonce, uint256 tokenId, uint256 amount)",
                address(nFTToken),
                signB,
                nonceB,
                tokenId2,
                amount
            )
        );
        assertEq(success, false, "error sign nft");
        vm.stopPrank();
    }

    function signAddress(address addr) internal returns (bytes memory signature, uint256 nce) {
        sigUtils = new SigUtils(tokenERC2612.DOMAIN_SEPARATOR());
        uint256 nonce = tokenERC2612.nonces(_owner);
        bytes32 hash = keccak256(abi.encodePacked(addr, nonce));
        hash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_ownerPrivateKey, hash);
        //签名
        return (abi.encodePacked(r, s, v), nce);
    }
}
