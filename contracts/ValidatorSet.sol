// 节点验证人
pragma solidity ^0.4.23;

import "./DemoStorage.sol";
import "../interface/ValidatorSetInterface.sol";

// v1.0 只有superuser可以添加或者移除节点验证人
// v2.0 投票移除或者添加节点验证人

contract ValidatorSet is ValidatorSetInterface{

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
        if(getIsIn(_someone)){
            _;
        }
    }

    modifier isPending(address _someone){
        if(getIsIn(_someone)){
            _;
        }
    }

    modifier isNotPending(address _someone){
        if(!getIsIn(_someone)){
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

    address[] validators;
    address[] pending;

    function initialValidators(address[] _initial) public {
        // address[] storage pending = new address[](demoStorage.getUint(keccak256("as")));
        pending = _initial;
        for(uint i = 0;i < _initial.length -1 ; i++){
            setIsIn(_initial[i],true);
            setIndex(_initial[i],i);
        }
        validators = pending;
    }

    function getValidators() public view returns(address[]){
        return validators;
    }

    function getPending() public view returns(address[]){
        return pending;
    }

    function finalizeChange() public onlySystemAndNotFinalized{
        validators = pending;
        setFinalized(true);
        emit ChangeFinalized(getValidators());
    }


    // 添加一个验证人
    function addValidator(address _validator) public onlySuperUser isNotPending(_validator){
        setIsIn(_validator,true);
        setIndex(_validator,pending.length);
        pending.push(_validator);
        initiateChange();
    }

    function removeValidator(address _validator) public onlySuperUser isPending(_validator){
        pending[getIndex(_validator)] = pending[pending.length - 1];
        delete pending[pending.length - 1];
        pending.length--;
        // Reset address status.
        // delete pendingStatus[_validator].index;
        delete getIndex(_validator);
        setIsIn(_validator,false);
        // pendingStatus[_validator].isIn = false;
        initiateChange();
    }

    // Called when a validator should be removed.
    function reportMalicious(address _validator, uint _blockNumber, bytes /* _proof */) public onlyOwner isRecent(_blockNumber) {
        emit Report(msg.sender, _validator, true);
    }

	// Report that a validator has misbehaved in a benign way.
    function reportBenign(address _validator, uint _blockNumber) public onlyOwner isValidator(_validator) isRecent(_blockNumber) {
        emit Report(msg.sender, _validator, false);
    }

    // Log desire to change the current list.
    function initiateChange() private whenFinalized {
        setFinalized(false);
        // solium-disable-next-line security/no-block-members
        emit InitiateChange(blockhash(block.number - 1), getPending());
    }


    // getter
    function getIsIn(address _someAddress) public view returns(bool){
        return demoStorage.getBool(keccak256("pending.status.is.in",_someAddress));
    }

    function getIndex(address _someAddress) public view returns(uint256){
        return demoStorage.getUint(keccak256("pending.status.index",_someAddress));
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
    function setIsIn(address _someAddress,bool _enable) public onlySuperUser{
        demoStorage.setBool(keccak256("pending.status.is.in",_someAddress),_enable);
    }

    function setIndex(address _someAddress,uint256 index) public onlySuperUser{
        demoStorage.setUint(keccak256("pending.status.index",_someAddress),index);
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