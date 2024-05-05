// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RuneERC20 is ERC20 {
    //铭文名称
    string _symbol;
    //已经发行量
    uint256 _balance;
    //总量
    uint256 _totalSupply;
    //单次发行量
    uint256 _perMint;
    //代币铸造费用
    uint256 _price;

    address private owner;

    mapping(address => uint256) public balancesAddr;

    //铸造代币名称：name, symbol
    constructor(
        address addr,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        owner = addr;
        _symbol = symbol;
        _balance = 0;
        _totalSupply = totalSupply;
        _perMint = perMint;
        _price = price;
        // _mint(addr, _perMint);
    }

    //开始铸造
    function mint(address addr, uint256 price) external {
        require(price > _price, "mint price is not enough");
        require(_totalSupply > (_balance + _perMint), "totalSupply is not enough");

        //开始铸造
        _mint(msg.sender, _perMint);
        _balance += _perMint;
        balancesAddr[addr] += _perMint;

        //每次铸造费用给own
        transfer(owner, price);
    }
}
