pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Airdrop {

    address private authority;


    constructor(address _authority) {
        authority = _authority;
    }

  function drop(address token, address[] memory recipients, uint256[] memory values) public {
      require(msg.sender == authority, "UNAUTHORIZED");
      for (uint256 i = 0; i < recipients.length; i++) {
        IERC20(token).transfer(recipients[i], values[i]);
    }
  }
}