pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract gCarFeeDistributor is ReentrancyGuard {

    address private gCarAddress;
    address private rentPoolFactoryAddress;
    address private authority;
    mapping(address => bool) private addressToSentThisCycle;
    address[] private sentAddresses;
    uint256 private cycleBalance;


    constructor(address gCarAddr, address rentPoolFactoryAddr, address _authority) ReentrancyGuard() {
        gCarAddress = gCarAddr;
        rentPoolFactoryAddress = rentPoolFactoryAddr;
        authority = _authority;
    }


    receive() external payable {

    }

    function resetCycle() external {
        require(msg.sender == authority, "UNAUTHORIZED");
        cycleBalance = 0;
        uint256 len = sentAddresses.length;
        for (uint i = len; i >=0; i--) {
            addressToSentThisCycle[sentAddresses[i]] = false;
            sentAddresses.pop();
        }
    }

    function setBalanceAtStartOfCycle() external {
        require(msg.sender == authority, "UNAUTHORIZED");
        cycleBalance = address(this).balance;
    }
    

    function claimFees(address to) external nonReentrant {
        sentAddresses.push(msg.sender);
        addressToSentThisCycle[msg.sender] = true;
        uint256 amount = IERC20(gCarAddress).balanceOf(msg.sender)/IERC20(gCarAddress).totalSupply() * 1e27 * cycleBalance;
        payable(to).transfer(amount);
    }

    function setAuthority(address newAuthority) external {
        require(msg.sender == authority, "UNAUTHORIZED");
        authority = newAuthority;
    }


    
}