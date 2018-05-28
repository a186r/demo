pragma solidity ^0.4.23;

//永久性存储
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