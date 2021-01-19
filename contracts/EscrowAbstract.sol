// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

import './EscrowStorage.sol';

abstract contract EscrowAbstract is EscrowStorage{
    function addEscrowPlan(
        string memory planName,
        address payable payer,
        address payable recipient,
        uint requiredAmount,
        uint escrowId 
    ) external virtual;
    function depositEther(uint escrowId) external virtual payable;
    function withdrawEther(uint escrowId) external virtual;

    event EscrowPlanCreated(
        string _planName,
        address indexed _payer,
        address indexed _recipient,
        uint _id
    );
    event EtherDeposited(
        uint _id, 
        address indexed _payer,
        uint _etherAmount
    );
    event EtherWithdrawed(
        uint _id,
        address indexed _recipient,
        uint _receivedAmount
    );

    modifier onlyLawyer { 
        require(msg.sender == lawyer, 'Only Lawyer!');
        _;
    }
}