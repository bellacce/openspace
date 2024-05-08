// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenERC2612.sol";

contract TokenBank {
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed _address, uint256 _amount);
    event Withdraw(address indexed _address, uint256 _amount);

    function deposit(address tokenAddress, uint256 _amount) public {
        TokenERC2612(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        // balanceOf[address(uint160(0xF8AE1707Cc40150B0bfF8CB09552B833Dbf13E3f))] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(address tokenAddress, uint256 tokenAmount) external {
        uint256 _amount = balanceOf[msg.sender];
        require(_amount > tokenAmount, "too many token to withdraw!");
        balanceOf[msg.sender] = 0;
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        emit Withdraw(msg.sender, tokenAmount);
    }

    function permitDeposit(address tokenAddress, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        TokenERC2612(tokenAddress).permit(msg.sender, address(this), amount, deadline, v, r, s); // _approve
        deposit(tokenAddress, amount);
    }
}
