// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

import './EscrowStorage.sol';

abstract contract EscrowAbstract is EscrowStorage{
    // functions to be implemented
    function addEscrowPlan(
        string memory planName,
        address payable payer,
        address payable receiver,
        uint requiredAmount,
        bytes32 escrowId 
    ) external virtual;
    function depositEther(bytes32 escrowId) external virtual payable;
    function withdrawEther(bytes32 escrowId) external virtual;

    // events
    event EscrowPlanCreated(
        string escrowPlanName,
        bytes32 escrowId,
        address indexed payer,
        address indexed receiver,
        uint requiredAmount,
        State state
    );
    event EtherDeposited(
        bytes32 escrowId, 
        address indexed payer,
        uint etherAmount,
        State state
    );
    event EtherWithdrawed(
        bytes32 escrowId, 
        address indexed receiver,
        uint receivedAmount,
        State state
    );

    // modifiers
    modifier onlyLawyer { 
        require(msg.sender == lawyer, 'Only Lawyer!');
        _;
    }
    modifier inState(bytes32 escrowId, State state) {
        require(plans[escrowId].state == state, 'Invalid State!');
        _;
    }
}