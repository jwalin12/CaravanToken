pragma solidity >= 0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IgCar.sol";

contract gCarRewardsManager {

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

    constructor(address _gCarAddress, address _authority, uint256 initSlope, uint256 initIntercept) {
        gCarAddress = _gCarAddress;
        authority = _authority;
        lastInflationParamChange = block.timestamp;
        slope = initSlope;
        intercept = initIntercept;

    }


    function calculateInflation() public view returns (uint256) {
        uint256 timeDelta = block.timestamp - lastInflationParamChange;
        return intercept + slope * timeDelta;
    }

    function calculateNextMintAmount() public view returns (uint256 nextMintAmount) {
        nextMintAmount = calculateInflation() - lastMintAmount;
        
    }

    function _mintToRewardContract(address rewardContract, uint256 amount) private {
        require(msg.sender == address(this));
        IgCar(gCarAddress).mint(rewardContract, amount);


    }


    function changeInflationParams(uint256 newIntercept, uint256 newSlope) external{
        require(msg.sender == authority);
        intercept = newIntercept;
        slope = newSlope;
        lastInflationParamChange = block.timestamp;

    }


    function distributeRewards() external {
        require(msg.sender == authority);
        uint256 nextMintAmount = calculateNextMintAmount();
        lastMintAmount = nextMintAmount;
        address currContract;
        for (uint i=0; i < rewardContracts.length; i++) {
            currContract = rewardContracts[i];
            uint256 amountToContract = ((rewardProportion[currContract]/precision) * nextMintAmount);
            _mintToRewardContract(currContract, amountToContract);
        }

    }

    //make sure to update reward contract proportions such that they all add up to the precision amount
    function addRewardContract(address newContract, uint256 proportion) external {
        require(msg.sender == authority);
        rewardContracts.push(newContract);
        rewardProportion[newContract] = proportion;

    }


    function updateRewardContractProportion(address rewardContract, uint256 newProportion) external {
        require(msg.sender == authority);
        rewardProportion[rewardContract] = newProportion;

    }







}