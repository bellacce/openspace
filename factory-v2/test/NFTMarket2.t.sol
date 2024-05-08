// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/TokenERC2612.sol";
import "../src/SigUtils.sol";
import "../src/NFTMarketV2.sol";
import "../src/NFTToken.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarket2Test is Test {
    TokenERC2612 internal tokenERC2612;
    SigUtils internal sigUtils;
    NFTMarketV2 internal nFTMarket;
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
        nFTToken = new NFTToken("WOENA", "ENA");

        vm.startPrank(_owner);
        //3.创造nft交易市场
        nFTMarket = new NFTMarketV2();
        nFTMarket.initialize(address(tokenERC2612));
        vm.stopPrank();
    }

    function test_listPermit() public {
        (address permitListA, uint256 permitListAkey) = makeAddrAndKey("permitListA");

        vm.startPrank(permitListA);
        //1.制作2个nft
        uint256 tokenId1 = nFTToken.mint(permitListA, "wwww.a.com");
        uint256 tokenId2 = nFTToken.mint(permitListA, "wwww.b.com");
        //一次性授权 内部有token所有人的地址信息
        nFTToken.setApprovalForAll(address(nFTMarket), true);
        //授权
        (bytes memory sign1A, uint256 nonce1A) = signAddress2(permitListA, permitListAkey, tokenId1);
        nFTMarket.listPermit(address(nFTToken), tokenId1, 10 * 10 ** 18, sign1A, nonce1A);

        (bytes memory sign2A, uint256 nonce2A) = signAddress2(permitListA, permitListAkey, tokenId2);
        nFTMarket.listPermit(address(nFTToken), tokenId2, 10 * 10 ** 18, sign2A, nonce2A);

        vm.stopPrank();
    }

    function signAddress2(address permitListA, uint256 permitListAkey, uint256 tokenId)
        internal
        returns (bytes memory signature, uint256 nce)
    {
        //        bytes32 result = abi.encodePacked(value);
        sigUtils = new SigUtils(tokenERC2612.DOMAIN_SEPARATOR());
        uint256 nonce = tokenERC2612.nonces(permitListA);
        bytes32 hash = keccak256(abi.encodePacked(permitListA, nonce, tokenId));
        hash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(permitListAkey, hash);
        //签名
        return (abi.encodePacked(r, s, v), nonce);
    }
}
