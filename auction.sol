// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
contract auction{
    function contract_balance() public view returns(uint) {return address(this).balance;}

    struct obj{
        address owner;
        address bidder;
        uint amt;
    }
    mapping(string=>obj) public mp;
    
    function sell_new_item(string memory id, uint amt) public payable{
        mp[id]=obj(msg.sender,msg.sender,amt);
    }
    
    function place_bid(string memory id, uint new_amt) public payable{
        address payable previous = payable(mp[id].bidder);
        uint prev_amt = mp[id].amt;
        previous.transfer(prev_amt);
        mp[id].bidder=msg.sender;
        mp[id].amt=new_amt;
    }

    function failed(string memory id) public{
        require(msg.sender==mp[id].bidder);
        address payable bidder = payable(mp[id].bidder);
        bidder.transfer(mp[id].amt);
        delete(mp[id]);
    }

    function completed(string memory id) public{
        require(msg.sender==mp[id].bidder);
        address payable owner = payable(mp[id].owner);
        owner.transfer(mp[id].amt);
        delete(mp[id]);
    }
}