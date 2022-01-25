pragma solidity >= 0.8.0;


import "../interfaces/IgaugeController.sol";


contract GaugeController is IgaugeController {

    mapping (address =>bool) authorities;
    uint256 inflationRate; //rate of rCAR inflation, divide by 
    mapping(address => uint256) gaugeToWeight;
    address[] gauges;
    mapping(address => uint256) gaugeToType;
    mapping(uint256 => uint256) gaugeTypeToWeight; //weights change week by week
    uint256 precision = 1e27;

    constructor(address authority) {
        authorities[authority] = true;

    }

    function addAuthority(address authority) external override {
        require(authorities[msg.sender]);
        authorities[authority] = true;
    }

    function addGauge(address gauge, uint256 gaugeWeight, uint256 gaugeType) external override {
        require(authorities[msg.sender]);
        gaugeToWeight[gauge] = gaugeWeight;
        gaugeToType[gauge] = gaugeType;
        gauges.push(gauge);

    }

    function addGaugeType(uint256 gaugeType, uint256 typeWeight) external override {
        gaugeTypeToWeight[gaugeType] = typeWeight;
    }


    function setGaugeWeight(address gauge, uint256 gaugeWeight) external override {
        require(authorities[msg.sender]);
        require(gaugeToWeight[gauge] == 0, "Gauge already exists");
        require(gaugeWeight >= 0, "Gauge cannot have negative weight");
        gaugeToWeight[gauge] = gaugeWeight;

    }



    function getRelativeGaugeWeight(address gauge) public view override returns (uint256) {
        uint256 totalWeight = 0;
        address currGauge;
        for(uint i = 0; i < gauges.length; i++) {
            currGauge = gauges[i];
            totalWeight += gaugeToWeight[currGauge] * gaugeTypeToWeight[gaugeToType[currGauge]];
        }
        require(totalWeight == 0, "No gauges inited");
        return ((gaugeToWeight[gauge] * gaugeTypeToWeight[gaugeToType[currGauge]]) / totalWeight) * precision;

    }





}