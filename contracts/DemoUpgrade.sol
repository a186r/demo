pragma solidity ^0.4.23;

import "./DemoBase.sol";
import "./DemoStorage.sol";
import "../interface/ERC20.sol";

// 合约更新
contract DemoUpgrade is DemoBase{
    
    ERC20 tokenContract = ERC20(0);

    event ContractUpgraded(
        address indexed _oldContractAddress,
        address indexed _newContractAddress,
        uint256 created
    );

    event ContractAdded( 
        address indexed _contractAddress,
        uint256 created
    );

    constructor (address _demoStorageAddress) DemoBase (_demoStorageAddress) public {
        version = 1;
    }

    // 合约升级方法

    // _name 要替换的合约名
    // _upgradedContractAddress 新的合约地址
    // _forceEther`
 
    function upgradeContract(string _name,address _upgradedContractAddress,bool _forceEther,bool _forceTokens) onlyOwner external {
        // 获取到要替换的合约
        address oldContractAddress = demoStorage.getAddress(keccak256(abi.encodePacked("contract.name",_name)));
        //检查是否存在
        // require(oldContractAddress != 0x0);

        // require(oldContractAddress != _upgradedContractAddress);

        // 非强制升级需要检查旧合约有没有余额
        if(!_forceEther){
            require(oldContractAddress.balance == 0);
        }

        if(!_forceTokens){
            tokenContract = ERC20(demoStorage.getAddress(keccak256(abi.encodePacked("contract.name","demoToken1"))));
            require(tokenContract.balanceOf(oldContractAddress) == 0);

            tokenContract = ERC20(demoStorage.getAddress(keccak256(abi.encodePacked("contract.name","demoToken2"))));
            require(tokenContract.balanceOf(oldContractAddress) == 0);
        }

        demoStorage.setAddress(keccak256(abi.encodePacked("contract.name",_name)),_upgradedContractAddress);

        demoStorage.setAddress(keccak256(abi.encodePacked("contract.address",_upgradedContractAddress)),_upgradedContractAddress);

        demoStorage.deleteAddress(keccak256(abi.encodePacked("contract.address",oldContractAddress)));

        emit ContractUpgraded(oldContractAddress,_upgradedContractAddress,now);

    }

    function addContract(string _name,address _contractAddress) onlyOwner external{
        require(_contractAddress != 0x0);

        // 检查名称没有被占用
        address existingContractName = demoStorage.getAddress(keccak256(abi.encodePacked("contract.name",_name)));
        require(existingContractName == 0x0);

        //检查地址，确保新合约地址没有出现过
        address existingContractAddress = demoStorage.getAddress(keccak256(abi.encodePacked("contract.address",_contractAddress)));
        require(existingContractAddress == 0x0);

        // 将合约名称和地址存储到storage
        demoStorage.setAddress(keccak256(abi.encodePacked("contract.name",_name)),_contractAddress);
        demoStorage.setAddress(keccak256(abi.encodePacked("contract.address",_contractAddress)),_contractAddress);

        emit ContractAdded(_contractAddress,now);
    }
}