pragma solidity ^0.4.23;

import "../interface/DemoStorageInterface.sol";

contract DemoBase {
    uint8 public version;   //版本号

    DemoStorageInterface demoStorage = DemoStorageInterface(0); 

    modifier onlyOwner(){
        roleCheck("owner",msg.sender);
        _;
    }

    modifier onlyAdmin(){
        roleCheck("admin",msg.sender);
        _;
    }

    modifier onlySuperUser(){
        require(roleHas("owner",msg.sender) || roleHas("admin",msg.sender));
        _;
    }

    modifier onlyRole(string _role){
        roleCheck(_role,msg.sender);
        _;
    }

    constructor (address _demoStorageAddress) public {
        demoStorage = DemoStorageInterface(_demoStorageAddress);
    }

    // 工具方法
    function roleHas(string _role,address _address) internal view returns (bool){
        return demoStorage.getBool(keccak256(abi.encodePacked("access.role",_role,_address)));
    }

    function roleCheck(string _role,address _address)view internal {
        require(roleHas(_role,_address) == true);
    }

}