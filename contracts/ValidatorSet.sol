pragma solidity ^0.4.23;

contract ValidatorSet {
    event InitiateChange(bytes32 indexed _parent_hash, address[] _new_set);
    function getValidators() public view returns (address[] _validators);
    function finalizeChange() public;
}
contract MajorityList is ValidatorSet {
    event ChangeFinalized(address[] current_set);
    struct ValidatorStatus {
        bool isValidator;
        uint index;
    }
    address SYSTEM_ADDRESS = 0xfffffffffffffffffffffffffffffffffffffffe;
    address[] public validatorsList;
    address[] pendingList;
    bool finalized;
    mapping(address => ValidatorStatus) validatorsStatus;
    bool private initialized;
    
    constructor() public {
        
        pendingList = [
            0x00Bd138aBD70e2F00903268F3Db08f2D25677C9e,
            0x00Aa39d30F0D20FF03a22cCfc30B7EfbFca597C2,
            0xd70db13e77dd64e7b3d53f2442912c26a68eaa7f,
            0xefda3009f218dafcb61a621c0ae4155c145047f5,
            0x88583fd765ec8d35bb748bb08c9a77ed1124d539
        ];

        initializeValidators();
    }
    modifier uninitialized() {
        if (initialized) { revert(); }
        _;
    }
    modifier when_finalized() {
        if (!finalized) { revert(); }
        _;
    }
    modifier only_system_and_not_finalized() {
        if (msg.sender != SYSTEM_ADDRESS || finalized) { revert(); }
        _;
    }
    modifier is_validator(address someone) {
        if (validatorsStatus[someone].isValidator) { _; }
    }
    modifier is_not_validator(address someone) {
        if (!validatorsStatus[someone].isValidator) { _; }
    }

    function initializeValidators() public uninitialized {
        for (uint j = 0; j < pendingList.length; j++) {
            address validator = pendingList[j];
            validatorsStatus[validator] = ValidatorStatus({
                isValidator: true,
                index: j
            });
        }
        initialized = true;
        validatorsList = pendingList;
        finalized = false;
    }
    function initiateChange() private when_finalized {
        finalized = false;
        InitiateChange(block.blockhash(block.number - 1), pendingList);
    }
    function finalizeChange() public only_system_and_not_finalized {
        validatorsList = pendingList;
        finalized = true;
        ChangeFinalized(validatorsList);
    }
    function addValidator(address validator) public  is_not_validator(validator){
        validatorsStatus[validator].index = pendingList.length;
        pendingList.push(validator);
        validatorsStatus[validator].isValidator = true;
        initiateChange();
    }
    function removeValidator(address validator) public is_validator(validator){
        uint removedIndex = validatorsStatus[validator].index;
        uint lastIndex = pendingList.length-1;
        address lastValidator = pendingList[lastIndex];

        pendingList[removedIndex] = lastValidator;
        validatorsStatus[lastValidator].index = removedIndex;

        delete pendingList[lastIndex];
        pendingList.length--;

        validatorsStatus[validator].index = 0;
        validatorsStatus[validator].isValidator = false;
        initiateChange();

    }
    function getValidators() public view returns (address[]) {
        return validatorsList;
    }
}