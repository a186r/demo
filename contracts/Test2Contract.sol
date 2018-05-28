pragma solidity ^0.4.23;

import "../lib/SafeMath.sol";
import "./DemoBase.sol";

contract Test2Contract is DemoBase{

    using SafeMath for uint;

    constructor(address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
        version = 1;
    }

    function setTest2Num1(uint _num) public onlySuperUser{
        demoStorage.setUint(keccak256("test2.num.1"),_num);
    }

    function getTest2Num1() public view returns (uint256){
        return demoStorage.getUint(keccak256("test2.num.1"));
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

}