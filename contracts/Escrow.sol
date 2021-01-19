// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

import './EscrowAbstract.sol';
import "./SafeMath.sol";

contract EscrowContract is EscrowAbstract {   
    // after deployment of contract, msg.sender will be lawyer
    constructor() {
        lawyer = msg.sender;
    }
    
    /**
    * @notice lawyer generate random id for attaching it
    * to it's escrow plan
    * 
    * @dev Warning: it isn’t an easy task to generate true random input. 
    * Do not rely on block.timestamp and block.difficulty as a source of randomness. 
    * Since these values can be manipulated by miners.
    * 
    * A good solution includes a combination of several pseudorandom data inputs and
    * the use of oracles or smart contracts to make it more reliable. 
    *
    * You need to be 100% sure nobody can tamper with the data 
    * that’s being inputted into your smart contract.
    * 
    * We will look at oracles later
    */
    function idGenerator() external view onlyLawyer() returns (uint) {
        return uint(keccak256(abi.encode(block.timestamp, block.difficulty)));
    }
    
    /**
    * @notice adding new escrow plan with an id 
    * 
    * remember id is generated via above function by lawyer
    *
    */
    function addEscrowPlan(
        string memory _planName,
        address payable _payer,
        address payable _recipient,
        uint _requiredAmount,
        uint _escrowId
    ) external override onlyLawyer() {
        require(plans[_escrowId].timestamp == 0, 'Existing Escrow!');
        
        // look at here: we are mutating storage, persistent action
        plans[_escrowId] = Escrow(
             _planName,
            _payer,
            _recipient,
            _requiredAmount,
            _escrowId,
            block.timestamp,
            State.PENDING
            );
        
        required[_escrowId] = _requiredAmount;

        emit EscrowPlanCreated(_planName, _payer, _recipient, _escrowId);
    }
    
    /**
    * @notice deposit Ether functionality, only payer can execute this function
    * 
    * @param _escrowId required plan id for deposit ether
    */
    function depositEther(uint _escrowId) external override payable {
        require(plans[_escrowId].timestamp > 0, 'Non-existing Escrow!');
        require(plans[_escrowId].state == State.PENDING, 'Only PENDING transactions!');
       
        require(msg.sender == plans[_escrowId].payer, "Only payer!");
        require(msg.value >= required[_escrowId], 'Invalid amount provided!');
        
        if (msg.value > required[_escrowId]) {
            fulfilled[_escrowId] = required[_escrowId];
            plans[_escrowId].payer.transfer(msg.value - required[_escrowId]);
            
            plans[_escrowId].state = State.ACTIVE;
        }
        
        fulfilled[_escrowId] = required[_escrowId];
        plans[_escrowId].state = State.ACTIVE;

        emit EtherDeposited(_escrowId, msg.sender, required[_escrowId]);
    }
    
    /**
    * @notice withdraw Ether functionality, only lawyer can execute this function
    * 
    * @param _escrowId required plan id for withdraw ether
    */
    function withdrawEther(uint _escrowId) external override onlyLawyer() {
        require(plans[_escrowId].state == State.ACTIVE, 'Only ACTIVE transactions!');
        
        plans[_escrowId].state = State.CLOSED;
        plans[_escrowId].recipient.transfer(fulfilled[_escrowId]);
        
        emit EtherWithdrawed(_escrowId, plans[_escrowId].recipient, required[_escrowId]);
    }

    /**
    * @return contract balance
    */
    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }
}