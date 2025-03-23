// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CharityPlatform {
    address public admin;
    
    struct Recipient {
        address payable wallet;
        string name;
        string reason;
        uint256 amountNeeded;
        bool approved;
        bool received;
    }
    
    mapping(address => Recipient) public recipients;
    address[] public recipientList;
    
    event DonationReceived(address indexed donor, uint256 amount);
    event RecipientRegistered(address indexed recipient, string name, string reason, uint256 amountNeeded);
    event RecipientApproved(address indexed recipient);
    event FundsTransferred(address indexed recipient, uint256 amount);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than zero");
        emit DonationReceived(msg.sender, msg.value);
    }
    
    // Register a recipient with user wallet address, name, reason, and amount needed
    function registerRecipient(
        address _userWallet, 
        string memory _name, 
        string memory _reason, 
        uint256 _amountNeeded
    ) external {
        require(recipients[_userWallet].wallet == address(0), "Recipient already registered");

        // Save the recipient information, including their wallet
        recipients[_userWallet] = Recipient(
            payable(_userWallet),   // The actual wallet address, set as payable
            _name,                  // Name of the recipient
            _reason,                // Reason for the request
            _amountNeeded,          // Amount they need
            false,                  // `approved` is initially false
            false                   // `received` is initially false
        );
        recipientList.push(_userWallet);

        emit RecipientRegistered(_userWallet, _name, _reason, _amountNeeded);
    }
    
    function approveRecipient(address _recipient) external onlyAdmin {
        require(recipients[_recipient].wallet != address(0), "Recipient not found");
        require(!recipients[_recipient].approved, "Already approved");
        
        recipients[_recipient].approved = true;
        emit RecipientApproved(_recipient);
    }
    
    function transferFunds(address _recipient) external onlyAdmin {
        require(recipients[_recipient].approved, "Recipient not approved");
        require(!recipients[_recipient].received, "Funds already transferred");
        require(address(this).balance >= recipients[_recipient].amountNeeded, "Not enough funds");
        
        recipients[_recipient].wallet.transfer(recipients[_recipient].amountNeeded);
        recipients[_recipient].received = true;
        emit FundsTransferred(_recipient, recipients[_recipient].amountNeeded);
    }

    // Function to get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to get all registered recipients
    function getAllRecipients() external view returns (address[] memory) {
        return recipientList;
    }

    // Function to donate to a specific recipient
    function donateToRecipient(address _recipient) external payable {
        require(msg.value > 0, "Donation must be greater than zero");
        require(recipients[_recipient].wallet != address(0), "Recipient not found");

        // Emit the event specifying the recipient
        emit DonationReceived(msg.sender, msg.value);

        // Transfer the donation directly to the recipient
        recipients[_recipient].wallet.transfer(msg.value);
    }

    // Withdraw function for approved recipients
    function withdraw() external {
        Recipient storage recipient = recipients[msg.sender];
        
        require(recipient.wallet != address(0), "Recipient not found");
        require(recipient.approved, "Recipient not approved");
        require(!recipient.received, "Funds already received");

        uint256 amount = recipient.amountNeeded;
        require(address(this).balance >= amount, "Not enough funds in the contract");

        // Transfer the funds to the recipient's wallet
        recipient.wallet.transfer(amount);
        recipient.received = true;

        emit FundsTransferred(msg.sender, amount);
    }
    function getAllRecipientDetails() external view returns (Recipient[] memory) {
    Recipient[] memory allRecipients = new Recipient[](recipientList.length);
    
    for (uint256 i = 0; i < recipientList.length; i++) {
        allRecipients[i] = recipients[recipientList[i]];
    }

    return allRecipients;
}

}
