//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11; 

contract FlipCoin {
    enum Side {NONE, HEAD, TAIL}

    struct Bet {
        uint id; 
        address seller; 
        address buyer; 
        Side sellerCh; 
        uint256 amount; 
        Side result; 
    }

    mapping(uint => Bet) public bets; 
    mapping(address => uint256) public pendingWithdrawals; 
    uint betCounter; 

    event startBetEvent(uint indexed _id); 
    event joinBetEvent(uint indexed _id, address _winner); 

    function startBet(uint _choice) payable public {
        betCounter++; 

        Side _sellerCh = Side.NONE; 
        if (_choice == 1) {
            _sellerCh = Side.HEAD; 
        } else {
            _sellerCh = Side.TAIL; 
        }

        // store the bet
        bets[betCounter] = Bet(
            betCounter,
            msg.sender, 
            address(0x0), 
            _sellerCh, 
            msg.value, 
            Side.NONE
        ); 

        // trigger the event 
        emit startBetEvent(betCounter); 
    }

    function getClosedBets() public view returns(uint[] memory) {
        if(betCounter == 0) {
            return new uint[](0); 
        }

        //create a long array to hold
        uint[] memory betIds = new uint[](betCounter); 

        uint numberOfClosedBets = 0; 
        for (uint i = 1; i <= betCounter; i++) {
            if (bets[i].buyer != address(0x0)) {
                betIds[numberOfClosedBets] = bets[i].id; 
                numberOfClosedBets++; 
            }
        }

        // copy it to a shorter array 
        uint[] memory closedBets = new uint[](numberOfClosedBets); 
        for (uint j = 0; j < numberOfClosedBets; j++) {
            closedBets[j] = betIds[j]; 
        }
        return closedBets; 
    }
   
    /* get and return an array of all the open bets at moment */ 
    function getOpenBets() public view returns(uint[] memory) {
        if (betCounter == 0) {
            return new uint[](0); 
        }

        // create a long array to hold 
        uint[] memory betIds = new uint[](betCounter); 

        uint numberOfOpenBets = 0; 
        for (uint i = 1; i <= betCounter; i++) {
            if (bets[i].buyer == address(0x0)) {
                betIds[numberOfOpenBets] = bets[i].id; 
                numberOfOpenBets++; 
            }
        }

        // copy it to a shorter array 
        uint[] memory openBets = new uint[](numberOfOpenBets); 
        for (uint j = 0; j < numberOfOpenBets; j++) {
            openBets[j] = betIds[j]; 
        }
        return openBets; 
    }

    
    /* Join an open bet */ 
    function joinBet(uint _id) payable public {
        require(_id > 0 && _id <= betCounter); 

        Bet storage bet = bets[_id]; 
        uint _amount = msg.value; 
        
        // require that there is no buyer already
        require(bet.buyer == address(0x0)); 
        require(bet.seller != msg.sender); 
        require(bet.amount == _amount); 
        require(bet.result == Side.NONE); 

        bet.buyer = msg.sender; 

        // select a rand side decide winner
        if (block.number % 2 == 0) {
            // head wins
            bet.result = Side.HEAD; 
        } else if (block.number % 2 == 1) {
            // buyer wins
            bet.result = Side.TAIL; 
        }

        address _winner = address(0x0); 
        if (bet.result == bet.sellerCh) {
            pendingWithdrawals[bet.seller] += bet.amount + _amount; 
            _winner = bet.seller; 
        } else {
            pendingWithdrawals[bet.buyer] += bet.amount + _amount; 
            _winner = bet.buyer; 
        }

        emit joinBetEvent(_id, _winner); 
    }
    
    /* let caller of contract withdraw his money */ 
    function withdraw() public {
        uint _amount = pendingWithdrawals[msg.sender]; 

        require(_amount > 0); 

        pendingWithdrawals[msg.sender] = 0; 
        payable(msg.sender).transfer(_amount); 
    }
}










