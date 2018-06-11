pragma solidity ^0.4.23;

import "../interface/ValidatorSetInterface.sol";
// import "./AddressVotes.sol";
import "../lib/safemath.sol";


contract MajoritySet is ValidatorSetInterface {

    using safemath for uint;
    
	// EVENTS
    event Report(address indexed reporter, address indexed reported, bool indexed malicious);
    event Support(address indexed supporter, address indexed supported, bool indexed added);
    event ChangeFinalized(address[] current_set);

// STATE

    // address[] memory supported = new address[](demoStorage.getUint(keccak256("address.total")));

	// 当前有权参与投票的地址列表
    address[] public validatorsList;
	// 等待列表
    address[] pendingList;
	// 最后的更改是否最终确定了
    bool finalized;
	// 每个地址的验证人状态
        // mapping(address => ValidatorStatus) validatorsStatus;

	// 可以使用结构体节约gas
    // AddressVotes.Data initialSupport;

    constructor (address _demoStorageAddress) DemoBase (_demoStorageAddress) public {
        version = 1;
        pendingList.push(0xf5777f8133aae2734396ab1d43ca54ad11bfb737);
        setInitialSupport(pendingList.length);

        for (uint i = 0; i < pendingList.length; i++) {
            address supporter = pendingList[i];
            setInitialSupportInserted(supporter,true);
        }

        for (uint j = 0; j < pendingList.length; j++) {
            address validator = pendingList[j];

            setIsValidator(validator,true);
            setIndex(validator,j);
        }

        validatorsList = pendingList;
        
    }

	// 获取验证人列表
    function getValidators() public view returns (address[]) {
        return validatorsList;
    }

	// Log desire to change the current list.
    function initiateChange() private whenFinalized {
        finalized = false;
        emit InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    function finalizeChange() public onlySystemAndNotFinalized {
        validatorsList = pendingList;
        finalized = true;
        emit ChangeFinalized(validatorsList);
    }

	// 查询验证人地址的支持数
    function getSupport(address _validator) public view returns (uint) {

        return demoStorage.getUint(keccak256(abi.encodePacked("addressvote.count",_validator)));
    }

	// 投票支持
    function addSupport(address _validator) public onlyValidator notVoted(_validator) {
        newStatus(_validator);
        // address[] memory supported = new address[](demoStorage.getUint(keccak256("nodes.total")));
        insert(_validator, msg.sender);
        // validatorsStatus[msg.sender].supported.push(validator);
        // 如果多数人支持，就添加为验证人
        addValidator(_validator);
        emit Support(msg.sender, _validator, true);
    }

	// 取消支持
    function removeSupport(address sender, address validator) private {
            // require(AddressVotes.remove(validator, sender));
        emit Support(sender, validator, false);
        // TODO:如果没有足够的支持者，就将验证者移除
        removeValidator(validator);
    }

    // 设置初始状态
    function newStatus(address _validator) private hasNoVotes(_validator){
        setIsValidator(_validator,false);
        setIndex(_validator,pendingList.length);
    }

	// 如果多数人支持，添加为验证人
    function addValidator(address validator) public isNotValidator(validator) hasHighSupport(validator) {
        // validatorsStatus[validator].index = pendingList.length;
        setIndex(validator,pendingList.length);        
        pendingList.push(validator);
        // validatorsStatus[validator].isValidator = true;
        setIsValidator(validator,true);
		// 新加入的验证人先投票给自己
        insert(validator, validator);
        // validatorsStatus[validator].supported.push(validator);
        initiateChange();
    }

	// 移除验证人
	// 也可以调用这个方法清除支持率较低的验证人
    function removeValidator(address _validator) public isValidator(_validator) hasLowSupport(_validator) {
        // uint removedIndex = validatorsStatus[validator].index;
        uint removedIndex = getIndex(_validator);
		// 不能移除最后一个验证人
        uint lastIndex = pendingList.length-1;
        address lastValidator = pendingList[lastIndex];
		// Override the removed validator with the last one.
        pendingList[removedIndex] = lastValidator;
		// Update the index of the last validator.
        // validatorsStatus[lastValidator].index = removedIndex;
        setIndex(lastValidator,removedIndex);
        delete pendingList[lastIndex];
        pendingList.length--;
		// 重置状态
        // validatorsStatus[_validator].index = 0;
        setIndex(_validator,0);
        // validatorsStatus[_validator].isValidator = false;
        setIsValidator(_validator,false);
		
        // 移除当初的支持者
        // address[] storage toRemove = validatorsStatus[_validator].supported;
        // for (uint i = 0; i < toRemove.length; i++) {
            // removeSupport(_validator, toRemove[i]);
        // }
        // delete validatorsStatus[_validator].supported;
        
        // 更新列表
        initiateChange();
    }

	// MODIFIERS

    function highSupport(address validator) public view returns (bool) {
        return getSupport(validator) > pendingList.length/2;
    }

    modifier hasHighSupport(address validator) {
        if (highSupport(validator)) { _; }
    }

    modifier hasLowSupport(address validator) {
        if (!highSupport(validator)) { _; }
    }

    modifier onlyValidator() {
        require(getIsValidator(msg.sender));
        _;
    }

    modifier isValidator(address _someone) {
        if(getIsValidator(_someone)){
            _;
        }
    }

    modifier isNotValidator(address _someone) {
        if(getIsValidator(_someone)){
            _;
        }
    }

    modifier notVoted(address _validator) {
        require(!contains(_validator));
        _;
    }

    modifier hasNoVotes(address _validator){
        if(getCount(_validator) == 0){
            _;
        }
    }

    modifier isRecent(uint _blockNumber) {
        // require(block.number <= _blockNumber + setRecentBlocks());
        _;
    }

    modifier onlySystemAndNotFinalized() {
        require(msg.sender == getSystemAddress() && !finalized);
        _;
    }

    modifier whenFinalized() {
        require(finalized);
        _;
    }

    // 是否已经投票
    function contains(address _voter) public view returns(bool){
        return demoStorage.getBool(keccak256("addressvote.inserted",_voter));
    }

	// _voter对地址_addr投票
    function insert(address _addr,address _voter) public returns (bool) {
        if(getInserted(_addr,_voter)) {return false;}
        setCount(_voter,getCount(_voter).add(1));
        setInserted(_addr,_voter,true);
        return true;
    }

	// _voter撤回对_addr的投票
    function remove(address _addr,address _voter) public returns (bool){
        if(getInserted(_addr,_voter)){return false;}
        setCount(_voter,getCount(_voter).sub(1));
        setInserted(_addr,_voter,false);
        return true;
    }

    // getter
    // 初始支持数
    function getInitialSupport () public view returns(uint256) {
        return demoStorage.getUint(keccak256(abi.encodePacked("majority.set.initialsupport")));
    }

    function getInitialSupportInserted(address _addr) public view returns(bool){
        return demoStorage.getBool(keccak256(abi.encodePacked("majority.set.initialsupport.inserted",_addr)));
    }

    function getIsValidator(address _addr) public view returns(bool){
        return demoStorage.getBool(keccak256(abi.encodePacked("majority.set.is.validator",_addr)));
    }

    function getIndex(address _addr) public view returns(uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("majority.set.index",_addr)));
    }

    function getRecentBlocks(address _addr) public view returns(uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("majority.set.recent.blocks",_addr)));
    }

    function getSystemAddress() public view returns(address){
        return demoStorage.getAddress(keccak256(abi.encodePacked("majority.set.system.address")));
    }

    // 地址得票数
    function getCount(address _addr) public view returns(uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("addressvote.count",_addr)));
    }

    function getInserted(address _addr,address _voter) public view returns(bool){
        return demoStorage.getBool(keccak256(abi.encodePacked("addressvote.inserted",_addr,_voter)));
    }



    // setter
    function setInitialSupport(uint256 _count) public onlySuperUser(){
        demoStorage.setUint(keccak256(abi.encodePacked("majority.set.initialsupport")),_count);
    }

    function setInitialSupportInserted(address _addr,bool _inserted) public onlySuperUser(){
        demoStorage.setBool(keccak256(abi.encodePacked("majority.set.initialsupport.inserted",_addr)),_inserted);
    }

    function setIsValidator(address _addr,bool _isvalidator) public onlySuperUser(){
        demoStorage.setBool(keccak256(abi.encodePacked("majority.set.is.validator",_addr)),_isvalidator);
    }

    function setIndex(address _addr,uint256 _index) public onlySuperUser(){
        demoStorage.setUint(keccak256(abi.encodePacked("majority.set.index",_addr)),_index);
    }

    function setRecentBlocks(uint256 _blocks) public onlySuperUser(){
        demoStorage.setUint(keccak256(abi.encodePacked("majority.set.recent.blocks")),_blocks);
    }

    function setSystemAddress(address _addr) public onlySuperUser(){
        demoStorage.setAddress(keccak256(abi.encodePacked("majority.set.system.address")),_addr);
    }

    // 地址得票数
    function setCount(address _addr,uint256 _count) public {
        demoStorage.setUint(keccak256(abi.encodePacked("addressvote.count",_addr)),_count);
    }

    // 是否投过票
    function setInserted(address _addr,address _voter,bool _is) public {
        demoStorage.setBool(keccak256(abi.encodePacked("addressvote.inserted",_addr,_voter)),_is);
    }
}