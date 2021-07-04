pragma solidity ^0.6.0;
contract Airlines {
    address chairperson; // address to refer to the identity of the chairperson
    
    // Airline data strucuture
    struct details { // struct to collectively define the data of the airlines, including the escrow or the deposit
        uint escrow; // deposit for payment settlement
        uint status;
        uint hashOfDetails; 
        }
        
        // Airline account payments and membership mapping
        // mapping to map account addresses (identities) of members to their details (A mapping is like a hash table.)
        mapping (address=>details) public balanceDetails;
        mapping (address=>uint) membership;
        
        // modifiers or rules
        // modifier for onlyChairperson rule
        modifier onlyChairperson{
            require(msg.sender==chairperson);
            _;
        }
        // modifier for onlyMember rule
        modifier onlyMember{
            require(membership[msg.sender]==1);
            _;
            
        }
        // constructor function
        constructor () public payable {
            // use of msg.sender and msg.value for a payable function
            chairperson=msg.sender;
            membership[msg.sender]=1; // automatically registered
            balanceDetails[msg.sender].escrow = msg.value;
        }
        
        // function of the contract
        function register ( ) public payable {
            // use of Usage of msg.sender and msg.value for a payable function
            address AirlineA = msg.sender;
            membership[AirlineA]=1;
            balanceDetails[msg.sender].escrow = msg.value;
        }
        
        function unregister (address payable AirlineZ) onlyChairperson public {
            if(chairperson!=msg.sender){
                revert(); }
                membership[AirlineZ]=0;
                // return escrow to leaving airline: verify other conditions
                AirlineZ.transfer(balanceDetails[AirlineZ].escrow);
                balanceDetails[AirlineZ].escrow = 0;
        }
        
        function request(address toAirline, uint hashOfDetails) onlyMember public {
            if(membership[toAirline]!=1){
                revert();
            }
            balanceDetails[msg.sender].status=0;
            balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
        }
        
        function response(address fromAirline, uint hashOfDetails, uint done) onlyMember public {
            if(membership[fromAirline]!=1){
                revert(); }
                balanceDetails[msg.sender].status=done;
                balanceDetails[fromAirline].hashOfDetails = hashOfDetails;
        }
        
        
        function settlePayment (address payable toAirline) onlyMember payable public {
            address fromAirline=msg.sender;
            uint amt = msg.value;
            balanceDetails[toAirline].escrow = balanceDetails[toAirline].escrow + amt;
            balanceDetails[fromAirline].escrow = balanceDetails[fromAirline].escrow - amt;
            
            // amt subtracted from msg.sender and given to toAirline
            // smart contract account transferring amount to an external account
            toAirline.transfer(amt);
        }
}

Ramamurthy, B. (2020). Blockchain in action. Manning Publications.
