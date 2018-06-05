pragma solidity ^0.4.15;

import "../contracts/DemoBase.sol";

contract AddressVotes is DemoBase{

    // struct Data {
    //     uint count;
    //     // 记录是否投过票
    //     mapping(address => bool) inserted;
    // }

    modifier notVoted(address _voter) {
        require(!getInserted(_voter));
        _;
    }

    modifier voted(address _voter){
        require(getInserted(_voter));
        _;
    }

    constructor (address _demoStorageAddress) DemoBase (_demoStorageAddress) public {
        version = 1;
    }

	// 总票数
    // function count(Data storage self) public view returns (uint) {
    //     return self.count;
    // }

	// 是否已经投过票
    // function contains(Data storage self, address voter) public view returns (bool) {
    //     return self.inserted[voter];
    // }
    
    // 是否已经投过票
    function getInserted(address _addr) public view returns(bool){
        return demoStorage.getBool(keccak256("addressvote.inserted",_addr));
    }

	// 投票
    function insert(address _voter) public notVoted (_voter) returns (bool) {
        setCount(_voter,getCount(_voter)+1);
        setInserted(_voter,true);
    }

    // function insert(Data storage self, address voter) public returns (bool) {
    //     if (self.inserted[voter]) { return false; }
    //     self.count++;
    //     self.inserted[voter] = true;
    //     return true;
    // }

	// 撤回投票
    function remove(address _voter) public voted (_voter) returns (bool){
        setCount(_voter,getCount(_voter)-1);
        setInserted(_voter,false);
    }

    // function remove(Data storage self, address voter) public returns (bool) {
    //     if (!self.inserted[voter]) { return false; }
    //     self.count--;
    //     self.inserted[voter] = false;
    //     return true;
    // }

    // getter
    function getCount(address _addr) public view returns(uint256){
        return demoStorage.getUint(keccak256("addressvote.count",_addr));
    }

    // setter
    function setCount(address _addr,uint256 _count) public onlySuperUser(){
        demoStorage.setUint(keccak256("addressvote.count",_addr),_count);
    }

    function setInserted(address _addr,bool _is) public onlySuperUser(){
        demoStorage.setBool(keccak256("addressvote.inserted",_addr),_is);
    }
}