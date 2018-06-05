pragma solidity ^0.4.15;

import "./DemoBase.sol";
import "../lib/SafeMath.sol";

contract AddressVotes is DemoBase{

    using SafeMath for uint;
    // struct Data {
    //     uint count;
    //     // 记录是否投过票
    //     mapping(address => bool) inserted;
    // }

    // modifier notVoted(address _voter) {
    //     require(!getInserted(_voter));
    //     _;
    // }

    // modifier voted(address _voter){
    //     require(getInserted(_voter));
    //     _;
    // }

    // inserted 一个地址对另一个地址是否投票，防止双重投票

    constructor (address _demoStorageAddress) DemoBase (_demoStorageAddress) public {
        version = 1;
    }

	// 总票数
    // function count(Data storage self) public view returns (uint) {
    //     return self.count;
    // }

	// 选民是否已经投票
    // function contains(Data storage self, address voter) public view returns (bool) {
    //     return self.inserted[voter];
    // }
    

    function contains(address _voter) public view returns(bool){
        return demoStorage.getBool(keccak256("addressvote.inserted",_voter));
    }

	// 投票
    function insert(address _addr,address _voter) public returns (bool) {
        if(getInserted(_addr,_voter)) {return false;}
        setCount(_voter,getCount(_voter).add(1));
        setInserted(_addr,_voter,true);
        return true;
    }

    // function insert(Data storage self, address voter) public returns (bool) {
    //     if (self.inserted[voter]) { return false; }
    //     self.count++;
    //     self.inserted[voter] = true;
    //     return true;
    // }

	// 撤回投票
    function remove(address _addr,address _voter) public returns (bool){
        if(getInserted(_addr,_voter)){return false;}
        setCount(_voter,getCount(_voter).sub(1));
        setInserted(_addr,_voter,false);
        return true;
    }

    // function remove(Data storage self, address voter) public returns (bool) {
    //     if (!self.inserted[voter]) { return false; }
    //     self.count--;
    //     self.inserted[voter] = false;
    //     return true;
    // }

    // getter
    function getCount(address _addr) public view returns(uint256){
        return demoStorage.getUint(keccak256(abi.encodePacked("addressvote.count",_addr)));
    }

    function getInserted(address _addr,address _voter) public view returns(bool){
        // return demoStorage.getBool(keccak256("addressvote.inserted",_addr));
        return demoStorage.getBool(keccak256(abi.encodePacked("addressvote.inserted",_addr,_voter)));
    }

    // setter

    // 地址得票数
    function setCount(address _addr,uint256 _count) public onlySuperUser(){
        demoStorage.setUint(keccak256(abi.encodePacked("addressvote.count",_addr)),_count);
    }

    /**
        @_addr 地址
        @_voter 投票人
        @_is 是否投票过
     */
    function setInserted(address _addr,address _voter,bool _is) public onlySuperUser(){
        demoStorage.setBool(keccak256(abi.encodePacked("addressvote.inserted",_addr,_voter)),_is);
    }
}