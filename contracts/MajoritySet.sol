pragma solidity ^0.4.23;

import "../interface/ValidatorSetInterface.sol";
import "../lib/AddressVotes.sol";

contract MajoritySet is ValidatorSetInterface {
	// EVENTS
    event Report(address indexed reporter, address indexed reported, bool indexed malicious);
    event Support(address indexed supporter, address indexed supported, bool indexed added);
    event ChangeFinalized(address[] current_set);

    struct ValidatorStatus {
        // 是否是验证人
        bool isValidator;
        // 验证人index
        uint index;
		// 支持这个地址的验证地址
        // AddressVotes.Data support;
		// 如果这个地址本身是验证人，它支持了哪些地址
        address[] supported;
		// Initial benign misbehaviour time tracker.
        // mapping(address => uint) firstBenign;
		// Repeated benign misbehaviour counter.
        // AddressVotes.Data benignMisbehaviour;
    }

    address constant SYSTEM_ADDRESS = 0xfffffffffffffffffffffffffffffffffffffffe;
	// Support can not be added once this number of validators is reached.
    // uint public constant MAX_VALIDATORS = 30;
	// Time after which the validators will report a validator as malicious.
    // uint public constant MAX_INACTIVITY = 6 hours;
	// Ignore misbehaviour older than this number of blocks.
    uint public constant RECENT_BLOCKS = 20;

// STATE

	// 当前有权参与投票的地址列表
    address[] public validatorsList;
	// 等待列表
    address[] pendingList;
	// 最后的更改是否最终确定了
    bool finalized;
	// 每个地址的验证人状态
    mapping(address => ValidatorStatus) validatorsStatus;

	// Used to lower the constructor cost.节约gas
    AddressVotes.Data initialSupport;

	// Each validator is initially supported by all others.
    function MajoritySet() public {
        pendingList.push(0xf5777f8133aae2734396ab1d43ca54ad11bfb737);

        initialSupport.count = pendingList.length;
        for (uint i = 0; i < pendingList.length; i++) {
            address supporter = pendingList[i];
            initialSupport.inserted[supporter] = true;
        }

        for (uint j = 0; j < pendingList.length; j++) {
            address validator = pendingList[j];
            validatorsStatus[validator] = ValidatorStatus({
                isValidator: true,
                index: j,
                support: initialSupport,
                supported: pendingList
                // benignMisbehaviour: AddressVotes.Data({ count: 0 })
            });
        }
        validatorsList = pendingList;
    }

	// 获取验证人列表
    function getValidators() public view returns (address[]) {
        return validatorsList;
    }

	// Log desire to change the current list.
    function initiateChange() private when_finalized {
        finalized = false;
        emit InitiateChange(block.blockhash(block.number - 1), pendingList);
    }

    function finalizeChange() public only_system_and_not_finalized {
        validatorsList = pendingList;
        finalized = true;
        emit ChangeFinalized(validatorsList);
    }

	// 查询验证人地址的支持数
    function getSupport(address validator) public view returns (uint) {
        return AddressVotes.count(validatorsStatus[validator].support);
    }

    function getSupported(address validator) public view returns (address[]) {
        return validatorsStatus[validator].supported;
    }

	// 投票支持验证者
    function addSupport(address validator) public only_validator not_voted(validator) {
        newStatus(validator);
        AddressVotes.insert(validatorsStatus[validator].support, msg.sender);
        validatorsStatus[msg.sender].supported.push(validator);
        addValidator(validator);
        emit Support(msg.sender, validator, true);
    }

	// 取消支持验证者
    function removeSupport(address sender, address validator) private {
        require(AddressVotes.remove(validatorsStatus[validator].support, sender));
        emit Support(sender, validator, false);
        // TODO:如果没有足够的支持者，就将验证者移除
        // removeValidator(validator);
    }

	// MALICIOUS BEHAVIOUR HANDLING

	// Called when a validator should be removed.
    // function reportMalicious(address validator, uint blockNumber, bytes proof) public only_validator is_recent(blockNumber) {
    //     removeSupport(msg.sender, validator);
    //     Report(msg.sender, validator, true);
    // }

	// BENIGN MISBEHAVIOUR HANDLING

	// Report that a validator has misbehaved in a benign way.
    // function reportBenign(address validator, uint blockNumber) public only_validator is_validator(validator) is_recent(blockNumber) {
    //     firstBenign(validator);
    //     repeatedBenign(validator);
    //     Report(msg.sender, validator, false);
    // }

	// Find the total number of repeated misbehaviour votes.
    // function getRepeatedBenign(address validator) public constant returns (uint) {
    //     return AddressVotes.count(validatorsStatus[validator].benignMisbehaviour);
    // }

	// Track the first benign misbehaviour.
    // function firstBenign(address validator) private has_not_benign_misbehaved(validator) {
    //     validatorsStatus[validator].firstBenign[msg.sender] = now;
    // }

	// Report that a validator has been repeatedly misbehaving.
    // function repeatedBenign(address validator) private has_repeatedly_benign_misbehaved(validator) {
    //     AddressVotes.insert(validatorsStatus[validator].benignMisbehaviour, msg.sender);
    //     confirmedRepeatedBenign(validator);
    // }

	// When enough long term benign misbehaviour votes have been seen, remove support.
    // function confirmedRepeatedBenign(address validator) private agreed_on_repeated_benign(validator) {
    //     validatorsStatus[validator].firstBenign[msg.sender] = 0;
    //     AddressVotes.remove(validatorsStatus[validator].benignMisbehaviour, msg.sender);
    //     removeSupport(msg.sender, validator);
    // }

	// Absolve a validator from a benign misbehaviour.
    // function absolveFirstBenign(address validator) public has_benign_misbehaved(validator) {
    //     validatorsStatus[validator].firstBenign[msg.sender] = 0;
    //     AddressVotes.remove(validatorsStatus[validator].benignMisbehaviour, msg.sender);
    // }

	// PRIVATE UTILITY FUNCTIONS

	// Add a status tracker for unknown validator.
    // function newStatus(address validator) private has_no_votes(validator) {
    //     validatorsStatus[validator] = ValidatorStatus({
    //         isValidator: false,
    //         index: pendingList.length,
    //         support: AddressVotes.Data({ count: 0 }),
    //         supported: new address[](0),
    //         benignMisbehaviour: AddressVotes.Data({ count: 0 })
    //     });
    // }

	// 如果多数人支持，添加为验证人
    function addValidator(address validator) public is_not_validator(validator) has_high_support(validator) {
        validatorsStatus[validator].index = pendingList.length;
        pendingList.push(validator);
        validatorsStatus[validator].isValidator = true;
		// 新加入的验证人先投票给自己
        AddressVotes.insert(validatorsStatus[validator].support, validator);
        validatorsStatus[validator].supported.push(validator);
        initiateChange();
    }

	// 移除验证人
	// 也可以调用这个方法清除支持率较低的验证人
    function removeValidator(address validator) public is_validator(validator) has_low_support(validator) {
        uint removedIndex = validatorsStatus[validator].index;
		// 不能移除最后一个验证人
        uint lastIndex = pendingList.length-1;
        address lastValidator = pendingList[lastIndex];
		// Override the removed validator with the last one.
        pendingList[removedIndex] = lastValidator;
		// Update the index of the last validator.
        validatorsStatus[lastValidator].index = removedIndex;
        delete pendingList[lastIndex];
        pendingList.length--;
		// 重置状态
        validatorsStatus[validator].index = 0;
        validatorsStatus[validator].isValidator = false;
		// 支持者的投票
        address[] storage toRemove = validatorsStatus[validator].supported;
        for (uint i = 0; i < toRemove.length; i++) {
            removeSupport(validator, toRemove[i]);
        }
        delete validatorsStatus[validator].supported;
        initiateChange();
    }

	// MODIFIERS

    function highSupport(address validator) public view returns (bool) {
        return getSupport(validator) > pendingList.length/2;
    }

    function firstBenignReported(address reporter, address validator) public view returns (uint) {
        return validatorsStatus[validator].firstBenign[reporter];
    }

    modifier has_high_support(address validator) {
        if (highSupport(validator)) { _; }
    }

    modifier has_low_support(address validator) {
        if (!highSupport(validator)) { _; }
    }

    modifier has_not_benign_misbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) == 0) { _; }
    }

    modifier has_benign_misbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) > 0) { _; }
    }

    modifier has_repeatedly_benign_misbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) - now > MAX_INACTIVITY) { _; }
    }

    // modifier agreed_on_repeated_benign(address validator) {
    //     if (getRepeatedBenign(validator) > pendingList.length/2) { _; }
    // }

    // modifier free_validator_slots() {
    //     require(pendingList.length < MAX_VALIDATORS);
    //     _;
    // }

    modifier only_validator() {
        require(validatorsStatus[msg.sender].isValidator);
        _;
    }

    modifier is_validator(address someone) {
        if (validatorsStatus[someone].isValidator) { _; }
    }

    modifier is_not_validator(address someone) {
        if (!validatorsStatus[someone].isValidator) { _; }
    }

    modifier not_voted(address validator) {
        require(!AddressVotes.contains(validatorsStatus[validator].support, msg.sender));
        _;
    }

    modifier has_no_votes(address validator) {
        if (AddressVotes.count(validatorsStatus[validator].support) == 0) { _; }
    }

    modifier is_recent(uint blockNumber) {
        require(block.number <= blockNumber + RECENT_BLOCKS);
        _;
    }

    modifier only_system_and_not_finalized() {
        require(msg.sender == SYSTEM_ADDRESS && !finalized);
        _;
    }

    modifier when_finalized() {
        require(finalized);
        _;
    }

    //     struct ValidatorStatus {
	// 	// Is this a validator.
    //     bool isValidator;
	// 	// Index in the validatorList.
    //     uint index;

	// 	// Validator addresses which supported the address.
    //     AddressVotes.Data support;

	// 	// Keeps track of the votes given out while the address is a validator.
    //     address[] supported;
	// 	// Initial benign misbehaviour time tracker.
    //     mapping(address => uint) firstBenign;
	// 	// Repeated benign misbehaviour counter.
    //     AddressVotes.Data benignMisbehaviour;
    // }

    // // getter
    // function getIsValidator(address _addr) public view returns(bool){
    //     return demoStorage.getBool(keccak256("majorityset.get.is.validator",_addr));
    // }

    // function getIndex(address _addr) public view returns(bool){
    //     return demoStorage.getUint(keccak256("majorityset.get.index",_addr));
    // }



    // // setter
    // function setIsValidator(address _addr,bool _is) public onlySuperUser{
    //     demoStorage.setBool(keccak256("majorityset.get.is.validator",_addr),_addr);
    // }

    // function getIndex(address _addr,uint256 _index) public onlySuperUser{
    //     demoStorage.setUint(keccak256("majorityset.get.index",_index),_index);
    // }

}