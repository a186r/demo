pragma solidity ^0.4.15;

import "../contracts/DemoBase.sol";
import "./SafeMath.sol";

contract AddressVotes is DemoBase{

    using SafeMath for uint;

    constructor (address _demoStorageAddress) DemoBase (_demoStorageAddress) public {
        version = 1;
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
    // 地址得票数
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