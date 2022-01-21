pragma solidity >= 0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";




interface IrCar is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address to, uint256 amount) external;

}