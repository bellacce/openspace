// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./WhiteInfo.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarket is IERC721Receiver {
    mapping(uint256 nftId => address account) public tokenHolder;
    mapping(uint256 nftId => uint256 amount) public tokenIdPrice;

    address public token;
    address public owner;

    //白名单合约地址
    WhiteInfo public whiteAddress;

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    constructor(address _token) {
        token = _token;
        //初始化白名单
        // whiteAddress = _whiteAddr;
        // whiteAddress = new WhiteAddress(msg.sender);
        owner = msg.sender;
    }

    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event Log(address from, address to, uint256 tokenId);

    //1.先上架
    function list(address nftToken, uint256 tokenId, uint256 amount) public {
        emit Log(msg.sender, address(this), tokenId);
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenId, "");
        tokenIdPrice[tokenId] = amount;
        tokenHolder[tokenId] = msg.sender;
    }

    //2.在购买,
    function buyNFT(address nftToken, uint256 tokenId, uint256 amount) internal {
        require(amount >= tokenIdPrice[tokenId], "no enough token to pay!");
        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");

        IERC20(token).transferFrom(msg.sender, tokenHolder[tokenId], tokenIdPrice[tokenId]);
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        //nft转移
        tokenHolder[tokenId] = msg.sender;
    }

    // function addToWhitelist(address _address) public {
    //     whiteAddress.addToWhitelist(_address);
    // }

    event PermitBuy(address signAddr, address sender, address owner);

    function permitBuy(address nftToken, bytes memory signature, uint256 nonce, uint256 tokenId, uint256 amount)
        public
    {
        //通过签名获取用户信息
        bytes32 digest = keccak256(abi.encodePacked(msg.sender, nonce)).toEthSignedMessageHash();
        //通过签名信息恢复加签的人的地址
        address signAddr = digest.recover(signature);
        //签名验证
        emit PermitBuy(signAddr, msg.sender, owner);

        require(signAddr == owner, "error sign nft");
        buyNFT(nftToken, tokenId, amount);
    }
}
