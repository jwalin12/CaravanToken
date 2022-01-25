pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IsrCar.sol";
import "../interfaces/IgCarRewardsManager.sol";


contract rCarStaker {

    address srCarAddress;
    address rCarAddress;
    address authority;
    address gCarRewardsManagerAddress;
    address gCarAddress;

    mapping(address => uint256) rCarStakedForAddress;
    mapping(address => uint256) intialDepositTime;
    mapping(address => uint256) stakingRewardsForStaker;
    mapping(address => uint256) stakerToIndex;
    address[] stakers;
    uint256 epochLength;
    uint256 epochRewards;
    uint256 minEpochStakedForRewards;



    constructor(address _srCarAddress, address _gCarAddress, address _gCarRewardsManagerAddress, address _authority) {
        srCarAddress = _srCarAddress;
        authority = _authority;
        gCarAddress = _gCarAddress;
        gCarRewardsManagerAddress = _gCarRewardsManagerAddress;
    }

    function stake(uint256 amount) external {
        if (rCarStakedForAddress[msg.sender] == 0) {
            stakers.push(msg.sender);
            stakerToIndex[msg.sender] = stakers.length-1;
            intialDepositTime[msg.sender] = block.timestamp;
        }
        rCarStakedForAddress[msg.sender] += amount;
        IsrCar(srCarAddress).mint(msg.sender, amount);
    }

    function updateStakingRewards() external {
        require(msg.sender == authority);
        for (uint i = 0; i < stakers.length; i++) {
            updateRewardsForStaker(stakers[i]);
        }
    }

    function updateRewardsForStaker(address staker) private {
        stakingRewardsForStaker[staker] += (rCarStakedForAddress[staker]/IERC20(srCarAddress).totalSupply()) * epochRewards;
    }

    function getProportionalStakingRewards(uint256 amount, address staker) private view returns (uint256) {
        return stakingRewardsForStaker[staker]  * (amount/rCarStakedForAddress[staker]);
    }

    function withdraw(uint256 amount, address to) external {
        require(rCarStakedForAddress[msg.sender] >= amount, "INSUFFICIENT AMOUNT STAKED");
        uint256 rewards = getProportionalStakingRewards(amount, msg.sender);
        rCarStakedForAddress[msg.sender] -= amount;
        if (block.timestamp > minEpochStakedForRewards * epochLength) {
            stakingRewardsForStaker[msg.sender] -= rewards;
            IERC20(gCarAddress).transfer(to, rewards);
        }
        IsrCar(srCarAddress).withdrawrCar(msg.sender, amount);
        if (rCarStakedForAddress[msg.sender]  == 0) {
            removeStaker(msg.sender);
        }
    }

    function removeStaker(address staker) private{
        delete(rCarStakedForAddress[staker]);
        delete(stakingRewardsForStaker[staker]);
        if (stakers.length > 1) {
            stakerToIndex[stakers[stakers.length - 1]] = stakerToIndex[staker];
            stakers[stakerToIndex[staker]] = stakers[stakers.length - 1]; 
        }
        stakers.pop();
        delete(stakerToIndex[staker]);
        delete(intialDepositTime[staker]);

    }


    function updateEpochRewards() external {
        require(msg.sender == authority);
        uint256 epochRewards = IgCarRewardsManager(gCarRewardsManagerAddress).mintToRewardContract(address(this));
    }

}