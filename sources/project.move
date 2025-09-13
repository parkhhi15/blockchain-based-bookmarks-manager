module MyModule::SimpleVoting {
    use aptos_framework::signer;
    
    /// Struct representing a voting poll
    struct Poll has store, key {
        yes_votes: u64,    // Number of yes votes
        no_votes: u64,     // Number of no votes
        is_active: bool,   // Whether the poll is still active
    }
    
    /// Struct to track if an address has already voted
    struct VoterRecord has store, key {
        has_voted: bool,
    }
    
    /// Error codes
    const E_POLL_NOT_ACTIVE: u64 = 1;
    const E_ALREADY_VOTED: u64 = 2;
    const E_POLL_NOT_EXISTS: u64 = 3;
    
    /// Function to create a new voting poll
    public fun create_poll(creator: &signer) {
        let poll = Poll {
            yes_votes: 0,
            no_votes: 0,
            is_active: true,
        };
        move_to(creator, poll);
    }
    
    /// Function to cast a vote on an existing poll
    public fun cast_vote(voter: &signer, poll_owner: address, vote_yes: bool) acquires Poll, VoterRecord {
        // Check if poll exists and is active
        assert!(exists<Poll>(poll_owner), E_POLL_NOT_EXISTS);
        let poll = borrow_global_mut<Poll>(poll_owner);
        assert!(poll.is_active, E_POLL_NOT_ACTIVE);
        
        // Check if voter has already voted
        let voter_addr = signer::address_of(voter);
        if (exists<VoterRecord>(voter_addr)) {
            let voter_record = borrow_global<VoterRecord>(voter_addr);
            assert!(!voter_record.has_voted, E_ALREADY_VOTED);
        } else {
            // Create voter record if it doesn't exist
            let voter_record = VoterRecord {
                has_voted: true,
            };
            move_to(voter, voter_record);
        };
        
        // Cast the vote
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        };
        
        // Mark voter as having voted
        if (exists<VoterRecord>(voter_addr)) {
            let voter_record = borrow_global_mut<VoterRecord>(voter_addr);
            voter_record.has_voted = true;
        };
    }
}