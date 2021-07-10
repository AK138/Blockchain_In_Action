pragma solidity >=0.4.0 <=0.8.0;
contract BallotV1 {
    
    // type Voter contains the voter details
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }
    
    // type Proposal contains proposal details; for now, it is only voteCount
    struct Proposal {
        uint voteCount;
    }
    
    // mapping of voter address to voter details
    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;
    
    // various phases (0, 1, 2, 3) of voting, state initialised to Init phase
    enum Phase {Init, Regs, Vote, Done}
    // if you remove the public visibility modifier from the state,
    // you will not see the state button in the user interface.
    Phase public state = Phase.Init;
    
    
    // modifier specifies access control rules to verify and 
    // manages who has control of data and functions to establish trust and privacy. 
    modifier validPhase(Phase reqPhase) 
    //modifier is called with three different actual parameters Regs, Vote, and Done
    
    // require(condition) declaration validates the condition passed as a parameter
    // and reverts the transaction if the check fails.
    { require(state == reqPhase); // a body of modifier that specifies the conditions to be checked within a require statement.
      _; 
    } 
    
    
    // constructor makes contract deployer the chairperson
    constructor (uint numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight 2 for testing purposes
        for (uint prop = 0; prop < numProposals; prop ++) //Number of proposals is a parameter for the constructor
        proposals.push(Proposal(0));
    }

    // function for changing Phase: can be done only by chairperson
    function changeState(Phase x) public {
        if (msg.sender != chairperson) {revert();} //Only chairperson can change state; otherwise, revert.
        if (x < state) revert(); //State has to progress in 0,1,2,3 order; otherwise, revert.
        state = x;
    }
    
    // modifier in the header of function.
    // if the condition is not met, revert the transaction
    function register(address voter) public validPhase(Phase.Regs) {
        if (msg.sender != chairperson || voters[voter].voted) revert(); 
        voters[voter].weight = 1;
        voters[voter].voted = false;
    }

   
    function vote(uint toProposal) public validPhase(Phase.Vote)  {
        Voter memory sender = voters[msg.sender];
        if (sender.voted || toProposal >= proposals.length) return; 
        sender.voted = true;
        sender.vote = toProposal;   
        proposals[toProposal].voteCount += sender.weight;
    }

    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++) 
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
    }
}
// Ramamurthy, B. (2020). Blockchain in action. Manning Publications.
