// 节点验证人
pragma solidity ^0.4.23;

import "./DemoBase.sol";
import "./DemoStorage.sol";
import "../interface/ValidatorSetInterface.sol";

// v1.0 只有superuser可以添加或者移除节点验证人
// v2.0 投票移除或者添加节点验证人

contract ValidatorSet is DemoBase,ValidatorSetInterface{

    event ValidatorAdded(
        address indexed _validatorAddress,
        uint256 created
    );

    event ValidatorRemoved(
        address indexed _validatorAddress,
        uint256 created
    );


    event Report(
        address indexed reporter, 
        address indexed reported, 
        bool indexed malicious
    );

    event ChangeFinalized(
        address[] currentSet
    );

    modifier onlySystemAndNotFinalized() {
        require(msg.sender != getSystemAddress() || getFinalized());
        _;
    }

    modifier whenFinalized(){
        require(!getFinalized());
        _;
    }

    modifier isValidator(address _someone){
        if(getIsin(_someone)){
            _;
        }
    }

    modifier isPending(address _someone){
        if(getIsin(_someone)){
            _;
        }
    }

    modifier isNotPending(address _someone){
        if(!getIsin(_someone)){
            _;
        }
    }

    modifier isRecent(uint256 _blockNumber){
        require(block.number <= _blockNumber + getRecentBlocks());
        _;
    }

    constructor (address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
        version = 1;
    }


    // getter

    function getIsin(address _someAddress) public view returns(bool){
        return demoStorage.getBool(keccak256("pending.status.is.in",_someAddress));
    }

    function getFinalized() public view returns (bool){
        return demoStorage.getBool(keccak256("volidatorset.finalized"));
    }

    function getRecentBlocks() public view returns (uint256){
        return demoStorage.getUint(keccak256("volidatorset.recent.blocks"));
    }

    function getSystemAddress() public view returns (address) {
        return demoStorage.getAddress(keccak256("volidatorset.system.address"));
    }

    // setter
    function setIsin(address _someAddress,bool _enable) public onlySuperUser{
        demoStorage.setBool(keccak256("pending.status.is.in",_someAddress),_enable);
    }

    function setFinalized(bool _enabled) public onlySuperUser{
        demoStorage.setBool(keccak256("volidatorset.finalized"),_enabled);
    }

    function setRecentBlocks(uint256 _recentBlocks) public onlySuperUser{
        demoStorage.setUint(keccak256("volidatorset.recent.blocks"),_recentBlocks);
    }

    function setSystemAddress(address _systemAddress)public onlySuperUser{
        demoStorage.setAddress(keccak256("volidatorset.system.address"),_systemAddress);
    }
}