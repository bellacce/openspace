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

    string _name;

    address private owner;

    mapping(address => uint256) public balancesAddr;

    //铸造代币名称：name, symbol
    constructor(address addr) ERC20("tmp_name", "tmp_symbol") {
        owner = addr;
        // emit Init(owner);
    }

    function init(uint256 totalSupply, uint256 perMint, uint256 price, string memory name, string memory symbol)
        external
    {
        // emit Init(owner);
        // emit Init(msg.sender);

        // require(address(0) != owner, "not init constart!");
        _balance = 0;
        _totalSupply = totalSupply;
        _perMint = perMint;
        _price = price;
        _name = name;
        _symbol = symbol;
    }

    event Mint(uint256 price, uint256 price1, uint256 price2);

    //开始铸造
    function mint(address projAddr, address upAddr, address addr) external payable {
        uint256 price = msg.value;

        require(price > _price, "mint price is not enough");
        require(_totalSupply > (_balance + _perMint), "totalSupply is not enough");

        //开始铸造
        _mint(msg.sender, _perMint);
        _balance += _perMint;
        balancesAddr[addr] += _perMint;

        //分配手续费 项目方占20%
        uint256 projAddrFee = (price * 20) / 100;
        uint256 upAddrFee = price - projAddrFee;

        emit Mint(price, projAddrFee, upAddrFee);

        payable(projAddr).transfer(projAddrFee);
        payable(upAddr).transfer(upAddrFee);
    }
}
