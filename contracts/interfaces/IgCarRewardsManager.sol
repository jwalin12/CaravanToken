pragma solidity >= 0.8.0;

interface IgCarRewardsManager {

    function mintToRewardContract(address rewardContract) external returns (uint256 amount);
    function calculateNextMintAmount() external view returns (uint256 nextMintAmount);
    function changeInflationParams(uint256 newIntercept, uint256 newSlope) external;
    function addRewardContract(address newContract, uint256 proportion) external;
    function updateRewardContractProportion(address rewardContract, uint256 newProportion) external;
    function calculateInflation() external view returns (uint256);


}