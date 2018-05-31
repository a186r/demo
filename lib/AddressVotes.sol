pragma solidity ^0.4.15;

import "../contract/DemoStorage.sol";
import "./contract/DemoBase";

library AddressVotes{
    // 记录每个地址的投票数并且记录地址是否投票

    // constructor(address _demoStorageAddress) DemoBase(_demoStorageAddress) public {
    //     // Version
    //     version = 1;
    // }

    struct Data{
        uint count;
        mapping (address=>bool) inserted;
    }

    // 投出的总票数
    function count(Data storage _self) public view returns(uint){
        return self.count;
    }

    fucntion contains(Data storage self,address voter) public view returns(bool){
        return self.inserted[voter];
    }

// 投票
    function insert(Data storage self,address voter) public returns(bool){
        if(self.inserted[voter]){
            return false;
        }
        self.count++;
        self.inserted[voter] = true;
        return true;
    }

// 撤回投票
    function remove(Data storage self,address voter)public returns(bool){
        if(!self.inserted[voter]){
            return false;
        }
        self.count--;
        self.inserted[voter] = false;
        return true;
    }

}