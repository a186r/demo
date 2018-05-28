pragma solidity ^0.4.23;

import "../lib/SafeMath.sol";
import "./DemoBase.sol";

contract TestContract is DemoBase{

    using SafeMath for uint;

    event SumNum(
        uint256 _TestNum1,
        uint256 _Test1Num1,
        uint256 created
    );
    
    constructor(address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
        version = 1;
    }

    function TwoNumSum(uint _num1,uint _num2) public {
        demoStorage.setUint(keccak256("test.twonumsum"),_num1.add(_num2));
    }

    function TwoNumSum2() public returns (uint) {
        return getTestNum1().add(getTest1Num1());
        // demoStorage.setUint(keccak256("test.twonumsum.2"),getTestNum1().add(14));
    }

    function setTestNum1(uint _num) public onlySuperUser{
        demoStorage.setUint(keccak256("test.num.1"),_num);
    }

    function getTestNum1() public view returns (uint256){
        return demoStorage.getUint(keccak256("test.num.1"));
    }

    function getTest1Num1() public view returns (uint256){
        return demoStorage.getUint(keccak256("test1.num.1"));
    }

    function getTest1Num2() public view returns (uint256){
        return demoStorage.getUint(keccak256("test1.num.2"));
    }

    function getSum() public view returns (uint256){
        return demoStorage.getUint(keccak256("test.twonumsum"));
    }

    function getSum2() public view returns (uint256){
        return demoStorage.getUint(keccak256("test.twonumsum.2"));
    }

    function deleteTestNum1() public {
        demoStorage.deleteUint(keccak256("test.num.1"));
    }

}