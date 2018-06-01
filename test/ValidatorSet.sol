pragma solidity ^0.4.23;

import "../interface/ValidatorSetInterface.sol";
import "./DemoStorage.sol";

contract MajorityList is ValidatorSetInterface {

    event ChangeFinalized(address[] current_set);

    struct ValidatorStatus {
        bool isValidator;
        uint index;
    }

    address[] public validatorsList;
    address[] pendingList;
    // bool finalized;
    // mapping(address => ValidatorStatus) validatorsStatus;
    // bool private initialized;
    
    constructor(address _demoStorageAddress)  DemoBase (_demoStorageAddress) public {
        version = 1;
        
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
        // if (getInitialized()) {
            // revert();
        // }
        // _;
        require(getInitialized());
        _;
    }
    modifier whenFinalized() {
        require(!getFinalized());
        _;
    }
    modifier onlySystemAndNotFinalized() {
        // if (msg.sender != getSystemAddress() || getFinalized()) {revert();}
        // _;
        require(msg.sender != getSystemAddress() || getFinalized());
        _;
    }
    modifier isValidator(address someone) {
        // if (validatorsStatus[someone].isValidator) { 
        // if(getIsValidator(someone)){
        //     _; 
        // }
        require(getIsValidator(someone));
        _;
    }
    modifier isNotValidator(address someone) {
        // if (!validatorsStatus[someone].isValidator) {
        // if(!getIsValidator(someone)){
        //     _; 
        // }

        require(!getIsValidator(someone));
        _;
    }

    function initializeValidators() public uninitialized {        
        // for (uint j = 0; j < pendingList.length; j++) {
        //     address validator = pendingList[j];
        //     // validatorsStatus[validator] = ValidatorStatus({
        //     //     isValidator: true,
        //     //     index: j
        //     // });
        //     setIsValidator(validator,true);
        //     setIndex(validator,j);
        // }
        // // initialized = true;
        // setInitialized(true);        
        // validatorsList = pendingList;
        // // finalized = false;
        // setFinalized(false);
    }

    function initiateChange() private whenFinalized {
        // finalized = false;
        setFinalized(false);
        emit InitiateChange(blockhash(block.number - 1), pendingList);
    }

    function finalizeChange() public onlySystemAndNotFinalized {
        validatorsList = pendingList;
        // finalized = true;
        setFinalized(true);
        emit ChangeFinalized(validatorsList);
    }

    function addValidator(address validator) public  isNotValidator(validator){
        // validatorsStatus[validator].index = pendingList.length;
        setIndex(validator,pendingList.length);
        pendingList.push(validator);
        // validatorsStatus[validator].isValidator = true;
        setIsValidator(validator,true);
        initiateChange();
    }

    function removeValidator(address validator) public isValidator(validator){
        // uint removedIndex = validatorsStatus[validator].index;
        uint removedIndex = getIndex(validator);
        uint lastIndex = pendingList.length-1;
        address lastValidator = pendingList[lastIndex];

        pendingList[removedIndex] = lastValidator;
        // validatorsStatus[lastValidator].index = removedIndex;
        setIndex(lastValidator,removedIndex);

        delete pendingList[lastIndex];
        pendingList.length--;

        // validatorsStatus[validator].index = 0;
        // validatorsStatus[validator].isValidator = false;
        setIndex(validator,0);
        setIsValidator(validator,false);
        initiateChange();

    }

    function getValidators() public view returns (address[]) {
        return validatorsList;
    }

    // getter
    function getSystemAddress() public view returns(address){
        return demoStorage.getAddress(keccak256("validator.get.system.address"));
    }

    function getIsValidator(address _someAddress) public view returns(bool){
        return demoStorage.getBool(keccak256("validator.get.is.validator",_someAddress));
    }

    function getIndex(address _someAddress) public view returns(uint256){
        return demoStorage.getUint(keccak256("validator.get.index",_someAddress));
    }

    function getFinalized() public view returns(bool){
        return demoStorage.getBool(keccak256("validator.get.finalized"));
    }

    function getInitialized() public view returns(bool){
        return demoStorage.getBool(keccak256("validator.get.initialized"));
    }

    // setter
    function setSystemAddress(address _systemAddress) public onlySuperUser{
        demoStorage.setAddress(keccak256("validator.get.system.address"),_systemAddress);        
    }

    function setIsValidator(address _someAddress,bool _is) public onlySuperUser{
        demoStorage.setBool(keccak256("validator.get.is.validator",_someAddress),_is);
    }

    function setIndex(address _someAddress,uint256 _index)public onlySuperUser{
        demoStorage.setUint(keccak256("validator.get.index",_someAddress),_index);
    }

    function setFinalized(bool _finalized) public onlySuperUser{
        demoStorage.setBool(keccak256("validator.get.finalized"),_finalized);
    }

    function setInitialized(bool _initialized) public onlySuperUser{
        demoStorage.setBool(keccak256("validator.get.initialized"),_initialized);
    }

}