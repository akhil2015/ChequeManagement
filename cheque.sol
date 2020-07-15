pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract Cheque {

    struct Cheque{
        string payee;
        address sender;
        address receiver;
        uint256 amount;
        uint256 startDate;
        uint256 expiryDate;
        uint256 nonce;
        bool subjectToApproval;
        bool approvalStatus;
        bool claimed;
    }
    event ChequeCreated();
    event ChequeClaimed();
    Cheque[] cheques;
    uint256 highestNonce=0;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public bankers;
    mapping(uint => bool) usedNonces;
    mapping(address => Cheque[]) receivedCheques;
    mapping(address => Cheque[]) sentCheques;

    constructor() public {
        bankers[msg.sender]=true;
    }
    modifier onlyRegisteredUser {
      require(whitelisted[msg.sender]);
      _;
    }
    modifier onlyBanker {
      require(bankers[msg.sender]);
      _;
    }
    function issueCheque(string memory payee, address receiver,uint256 amount, uint256 startDate, uint256 expiryDate,bool subjectToApproval) public onlyRegisteredUser {
        Cheque memory _cheque =  Cheque(payee,msg.sender,receiver,amount,startDate,expiryDate,highestNonce,subjectToApproval,false,false);
        cheques.push(_cheque);
        highestNonce++;
        Cheque[] storage sent = sentCheques[msg.sender];
        sent.push(_cheque);
        sentCheques[msg.sender]=sent;
        Cheque[] storage received = receivedCheques[receiver];
        received.push(_cheque);
        receivedCheques[receiver]=received;
    }
    function claimCheque(uint256 index) onlyRegisteredUser public {
        require(!usedNonces[index],"Nonce has already been used");
        usedNonces[index] = true;
        emit ChequeClaimed();
    }
    function addUser(address user) onlyBanker public {
        whitelisted[user] = true;
    }
    function addBanker(address _banker) onlyBanker public {
        bankers[_banker] = true;
    }
    function approveChequeRedemption(uint256 index)onlyBanker public {
        require(cheques[index].subjectToApproval);
        cheques[index].approvalStatus = true;
    }
    function retrieveSentCheques() onlyRegisteredUser public returns (Cheque[] memory return_data){
        Cheque[] memory sent= sentCheques[msg.sender];
        return_data = sent;
    }
    function retrieveReceivedCheques() onlyRegisteredUser public returns (Cheque[] memory return_data){
        Cheque[] memory received= receivedCheques[msg.sender];
        return_data = received;
    }
    function retrieveAllCheques()onlyBanker public view returns (Cheque[] memory){
        return cheques;
    }
}
