pragma solidity 0.7.5;
pragma abicoder v2;

contract Wallet {
    address[] public owners;
    uint limit;
    
    struct Transfer{
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }
    
    event transferRequestCreated(uint _id, uint _amount, address _initator, address _receiver);
    event approvalReceived(uint _id,uint approvals,address _approver);
    event transferApproved(uint _id);
    
    Transfer[] transferRequests;
    
    mapping(address => mapping(uint => bool)) approvals;
    
    //Should only allow people in the owners list to continue the execution.
    // for loop to ensure the amount of owners is set correctly, it will loop through all the addresses
    //require to ensure that this won't work unless it is true
    modifier onlyOwners(){
        bool owner = false;
        for(uint i=0; i < owners.length; i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner == true);
        _;
    }
    //initialize the owners list and the limit for approval to transfer
    constructor(address[] memory _owners, uint _limit) {
        owners = _owners;
        limit = _limit;
    }
    
    //deposit
    function deposit() public payable {}
    
    //Create an instance of the Transfer struct and add it to the transferRequests array
    // below is going throught the Transfer struct 
    // the transferRequests.length is using the above array which starts fron 0
    // then the transferRequests.push puts it within the array
    // the mofifier onlyOwners is so that owners are the only ones who can create a transfer
    function createTransfer(uint _amount, address payable _receiver) public onlyOwners {
        
         emit transferRequestCreated(transferRequests.length, _amount, msg.sender,_receiver);
         transferRequests.push(
             Transfer(_amount, _receiver, 0, false, transferRequests.length)
             );
         
         }
        
    
    
   //all of these are accessed using the struct at the top
   //1st require stops an owner from voting twice
   //2nd require stops an owner from voting on a transfer that has already been hasBeenSent
   //approvals uses the double mapping
   // transfer request adds an approval vote
   // next line sets it to the limit so that when it is reached the funds will transferRequests
   //lastly, is the transfer
    function approve(uint _id) public onlyOwners {
        
    require (approvals[msg.sender][_id] ==false);
    require(transferRequests[_id].hasBeenSent ==false);
    
    approvals[msg.sender][_id]= true;
    transferRequests[_id].approvals++;
    
    emit approvalReceived(_id, transferRequests[_id].approvals, msg.sender); 
    
    if(transferRequests[_id].approvals >= limit){
        transferRequests[_id].hasBeenSent = true;
        transferRequests[_id].receiver.transfer(transferRequests[_id].amount);
    emit transferApproved(_id);
    }
    
 }   
    //return all transfer requests
    
    function getTransferRequests () public view returns (Transfer[] memory){
        return transferRequests;
    }
    
    
}
