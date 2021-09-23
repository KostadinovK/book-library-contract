pragma solidity >=0.7.0 <0.9.0;

contract Owner {

    address private owner;
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
}
