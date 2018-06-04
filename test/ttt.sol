pragma solidity ^0.4.23;

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
        return demoStorage.getBool(keccak256("access.role",_role,_address));
    }

    function roleCheck(string _role,address _address)view internal {
        require(roleHas(_role,_address) == true);
    }

}

contract DemoStorage {

    mapping (bytes32=>uint256) private uIntStorage;
    mapping (bytes32=>string) private stringStorage;
    mapping (bytes32=>address) private addressStorage;
    mapping (bytes32=>bool) private boolStorage;
    mapping (bytes32=>bytes) private bytesStorage;
    mapping (bytes32=>int256) private intStorage;

    // Modifiers

// 确保只有最新的合约可以调用
    modifier onlyLatestNetworkContract(){

        if(boolStorage[keccak256("contract.storage.initialised")] == true){
            require(addressStorage[keccak256("contract.address",msg.sender)] != 0x0);
        }
        _;
    }

    //设置owner
    constructor () public {
        boolStorage[keccak256("access.role","owner",msg.sender)] = true;
    }

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }
    
    /**** Set Methods ***********/

    function setAddress(bytes32 _key, address _value) onlyLatestNetworkContract external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) onlyLatestNetworkContract external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) onlyLatestNetworkContract external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) onlyLatestNetworkContract external {
        bytesStorage[_key] = _value;
    }
    
    function setBool(bytes32 _key, bool _value) onlyLatestNetworkContract external {
        boolStorage[_key] = _value;
    }
    
    function setInt(bytes32 _key, int _value) onlyLatestNetworkContract external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods ***********/
    
    function deleteAddress(bytes32 _key) onlyLatestNetworkContract external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) onlyLatestNetworkContract external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) onlyLatestNetworkContract external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) onlyLatestNetworkContract external {
        delete bytesStorage[_key];
    }
    
    function deleteBool(bytes32 _key) onlyLatestNetworkContract external {
        delete boolStorage[_key];
    }
    
    function deleteInt(bytes32 _key) onlyLatestNetworkContract external {
        delete intStorage[_key];
    }
}

contract DemoStorageInterface {
    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string);
    function getBytes(bytes32 _key) external view returns (bytes);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
    // Setters
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    
}

contract ValidatorSetInterface is DemoBase{
    /// Issue this log event to signal a desired change in validator set.
    /// This will not lead to a change in active validator set until
    /// finalizeChange is called.
    ///
    /// Only the last log event of any block can take effect.
    /// If a signal is issued while another is being finalized it may never
    /// take effect.
    ///
    /// _parent_hash here should be the parent block hash, or the
    /// signal will not be recognized.
    event InitiateChange(bytes32 indexed _parent_hash, address[] _new_set);

    /// Get current validator set (last enacted or initial if no changes ever made)
    function getValidators() public view returns (address[] _validators);

    /// Called when an initiated change reaches finality and is activated.
    /// Only valid when msg.sender == SUPER_USER (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    function finalizeChange() public;
	// Reporting functions: operate on current validator set.
	// malicious behavior requires proof, which will vary by engine.

    function reportBenign(address validator, uint256 blockNumber) public;
    function reportMalicious(address validator, uint256 blockNumber, bytes proof) public;
}

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
    address[] pending = [
        0x00Bd138aBD70e2F00903268F3Db08f2D25677C9e,
        0x00Aa39d30F0D20FF03a22cCfc30B7EfbFca597C2,
        0xd70db13e77dd64e7b3d53f2442912c26a68eaa7f
    ];

    function initialValidators() public {
        // address[] storage pending = new address[](demoStorage.getUint(keccak256("as")));
        // pending = _initial;
        // for(uint i = 0;i < _initial.length -1 ; i++){
        //     setIsIn(_initial[i],true);
        //     setIndex(_initial[i],i);
        // }
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
        //TODO: delete getIndex(_validator);
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
