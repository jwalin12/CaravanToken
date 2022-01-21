pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IgCar.sol";
import "../interfaces/IgCarRewardsManager.sol";

contract gCarRewardsManager is IgCarRewardsManager {

    using SafeMath for uint256;

    address private immutable gCarAddress;
    address private authority;
    uint256 private intercept;
    uint256 private slope;
    uint256 private lastInflationParamChange;
    uint256 private lastMintAmount;
    uint256 private precision = 1e4;
    address[] rewardContracts;
    mapping(address => uint256) rewardProportion;
    mapping(address => uint256) rewardsToPayOut;

    constructor(address _gCarAddress, address _authority, uint256 initSlope, uint256 initIntercept) {
        gCarAddress = _gCarAddress;
        authority = _authority;
        lastInflationParamChange = block.timestamp;
        slope = initSlope;
        intercept = initIntercept;

    }


    function calculateInflation() public override view returns (uint256) {
        uint256 timeDelta = block.timestamp - lastInflationParamChange;
        return intercept + slope * timeDelta;
    }

    function calculateNextMintAmount() public override view returns (uint256 nextMintAmount) {
        nextMintAmount = calculateInflation() - lastMintAmount;
        
    }

    function mintToRewardContract(address rewardContract) external override returns (uint256 amount) {
        require(msg.sender == rewardContract || msg.sender == authority);
        updateRewardBalances();
        amount = rewardsToPayOut[rewardContract];
        rewardsToPayOut[rewardContract] = 0;
        IgCar(gCarAddress).mint(rewardContract, amount);

    }


    function changeInflationParams(uint256 newIntercept, uint256 newSlope) external override {
        require(msg.sender == authority);
        intercept = newIntercept;
        slope = newSlope;
        lastInflationParamChange = block.timestamp;

    }


    function updateRewardBalances() private {
        require(msg.sender == authority);
        uint256 nextMintAmount = calculateNextMintAmount();
        lastMintAmount = nextMintAmount;
        address currContract;
        for (uint i=0; i < rewardContracts.length; i++) {
            currContract = rewardContracts[i];
            uint256 amountToContract = ((rewardProportion[currContract]/precision) * nextMintAmount);
            rewardsToPayOut[currContract] = rewardsToPayOut[currContract] + amountToContract;
        }

    }

    //make sure to update reward contract proportions such that they all add up to the precision amount
    function addRewardContract(address newContract, uint256 proportion) external override {
        require(msg.sender == authority);
        rewardContracts.push(newContract);
        rewardProportion[newContract] = proportion;

    }

    function updateRewardContractProportion(address rewardContract, uint256 newProportion) external override {
        require(msg.sender == authority);
        rewardProportion[rewardContract] = newProportion;

    }







}