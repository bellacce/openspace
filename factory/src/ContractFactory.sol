pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RuneERC20.sol";
/**
 * 在以太坊上⽤ ERC20 模拟铭⽂铸造，编写一个可以通过最⼩代理来创建ERC20 的⼯⼚合约，⼯⼚合约包含两个方法：
 *
 * • deployInscription(string symbol, uint totalSupply, uint perMint, uint price), ⽤户调⽤该⽅法创建 ERC20 Token合约，
 *  symbol 表示新创建代币的代号
 *  （ ERC20 代币名字可以使用固定的），
 * totalSupply 表示总发行量， perMint 表示单次的创建量， price 表示每个代币铸造时需要的费用（wei 计价）。每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。
 * • mintInscription(address tokenAddr) payable: 每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用。
 * 要求：
 * 包含测试用例：
 * 费用按比例正确分配到发行者账号及项目方账号。
 * 每次发行的数量正确，且不会超过 totalSupply.
 * 请包含运行测试的截图或日志
 */

contract ContractFactory {
    //已经部署的合约地址
    address[] public deployedContracts;
    string[] public symbols;

    //事件部署标记
    event DeployInscription(string symbol, uint256 totalSupply, uint256 perMint, uint256 price);
    //铸造代币
    event MintInscription(address tokenAddr, uint256 value);

    // symbol 表示新创建代币的代号，
    // totalSupply 表示总发行量，
    // perMint 表示单次的创建量，
    // price 表示每个代币铸造时需要的费用（wei 计价）
    function deployInscription(string memory symbol, uint256 totalSupply, uint256 perMint, uint256 price)
        external
        returns (address addr)
    {
        require(!symbolExists(symbol), "Symbol already exists");
        //创建合约
        RuneERC20 rune = new RuneERC20(msg.sender, totalSupply, perMint, price, symbol, symbol);
        //添加部署合约
        deployedContracts.push(address(rune));
        symbols.push(symbol);

        emit DeployInscription(symbol, totalSupply, perMint, price);
        return address(rune);
    }

    //每次调用发行创建时确定的 `perMint` 数量的 token，并收取相应的费用。
    function mintInscription(address tokenAddr) public payable {
        emit MintInscription(tokenAddr, msg.value);

        //开始铸造
        RuneERC20(tokenAddr).mint(msg.sender, msg.value);
    }

    //检查符文是否存在
    function symbolExists(string memory symbol) internal view returns (bool) {
        for (uint256 i = 0; i < symbols.length; i++) {
            if (keccak256(abi.encodePacked(symbols[i])) == keccak256(abi.encodePacked(symbol))) {
                return true;
            }
        }
        return false;
    }
}
