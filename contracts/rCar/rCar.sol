pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";




contract rCAR is ERC20Burnable {


    address private authority;
    mapping(address => bool) isMinter;


    constructor(address _authority) public ERC20("Caravan rebate", "rCAR") ERC20Burnable() {
        authority = _authority;
    }


    function addMinter(address newMinter) external {
        require(msg.sender == authority);
        isMinter[newMinter] = true;

    }

    function removeMinter(address minter) external {
        require(msg.sender == authority);
        isMinter[minter] = false;

    }

    function mint(address to, uint256 amount) external {
        require(isMinter[msg.sender] , "unauthorized");
        _mint(to, amount);

    }


}