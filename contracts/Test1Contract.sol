pragma solidity ^0.4.23;

import "../lib/SafeMath.sol";
import "./DemoBase.sol";

contract Test1Contract is DemoBase{
    
    constructor(address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
        version = 1;
    }

    function setTest1Num1(uint _num) public onlySuperUser{
        demoStorage.setUint(keccak256(abi.encodePacked("test1.num.1")),_num);
    }

    function setTest1Num2(uint _num) public onlySuperUser{
        demoStorage.setUint(keccak256(abi.encodePacked("test1.num.2")),_num);
    }

}