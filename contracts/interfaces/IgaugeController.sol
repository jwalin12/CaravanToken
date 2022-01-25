pragma solidity >= 0.8.0;



interface IgaugeController {

    function addGauge(address gauge, uint256 gaugeWeight, uint256 gaugeType) external;
    function addAuthority(address authority) external;
    function addGaugeType(uint256 gaugeType, uint256 typeWeight) external;
    function setGaugeWeight(address gauge, uint256 gaugeWeight) external;
    function getRelativeGaugeWeight(address gauge) external view returns (uint256);


}