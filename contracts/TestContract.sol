pragma solidity ^0.4.23;

import "../lib/SafeMath.sol";
import "./DemoBase.sol";
import "../lib/ds-guard.sol";

contract TestContract is DemoBase,DSGuard{

    using SafeMath for uint;

    DSGuard public dsguard;

    event SumNum(
        uint256 _TestNum1,
        uint256 _Test1Num1,
        uint256 created
    );
    
    constructor(address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
        version = 1;
    }

    function setGuard() public onlySuperUser{
        dsguard.permit(
            msg.sender,
            demoStorage.getAddress(keccak256(abi.encodePacked("contract.name","Test1Contract")),
            ANY
        );
    }

    function TwoNumSum(uint _num1,uint _num2) public {
        demoStorage.setUint(keccak256(abi.encodePacked("test.twonumsum")),_num1.add(_num2));
    }

    function TwoNumSum2() public returns (uint) {
        emit SumNum(getTestNum1(),getTest1Num1(),now);
        return getTestNum1().add(getTest1Num1());
        // demoStorage.setUint(keccak256("test.twonumsum.2"),getTestNum1().add(14));
    }

    function setTestNum1(uint _num) public onlySuperUser{
        demoStorage.setUint(keccak256(abi.encodePacked("test.num.1")),_num);
    }

    function getTestNum1() public view returns (uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("test.num.1")));
    }

    function getTest1Num1() public view returns (uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("test1.num.1")));
    }

    function getTest1Num2() public view returns (uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("test1.num.2")));
    }

    function getSum() public view returns (uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("test.twonumsum")));
    }

    function getSum2() public view returns (uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("test.twonumsum.2")));
    }

    function deleteTestNum1() public {
        demoStorage.deleteUint(keccak256(abi.encodePacked("test.num.1")));
    }

}