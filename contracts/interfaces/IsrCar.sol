pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IsrCar {
    
    function mint(address to, uint256 amount) external;
    function withdrawrCar(address to,uint256 amount) external;



}
