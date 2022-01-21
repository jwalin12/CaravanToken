pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

import "./interfaces/IgCar.sol";



contract gCAR is ERC20Capped, IgCar {


    address private minter;


    constructor(address _minter, address vestingContract, address airdropManager, address treasury) public ERC20("Caravan governance", "gCAR") ERC20Capped(500000) {
        minter = _minter;

        //TODO: mint initial supply to vesting contracts + airdrop holder + treasury based on distribution
    }

    function mint(address to, uint256 amount) external override {
        require(msg.sender == minter, "unauthorized");
        _mint(to, amount);

    }


}