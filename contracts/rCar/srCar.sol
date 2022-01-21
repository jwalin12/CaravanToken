pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../interfaces/IrCar.sol";


contract srCAR is ERC20Burnable {

        address authority;
        address rCarAddress;


    constructor(address _authority, address _rCarAddress) public ERC20("Caravan rebate", "rCAR") ERC20Burnable() {
        authority = _authority;
        rCarAddress = _rCarAddress;
    }

    function mint(address to, uint256 amount) external {
        IrCar(rCarAddress).burnFrom(msg.sender, amount);
        _mint(to, amount);

    }

    function withdrawrCar(address to,uint256 amount) external {
        burnFrom(msg.sender,amount);
        //should have minter role for rCar
        IrCar(rCarAddress).mint(to, amount);


    }












}