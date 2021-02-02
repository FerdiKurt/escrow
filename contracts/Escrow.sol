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
    function idGenerator(
        address payable _payer,
        address payable _receiver,
        uint _requiredAmount
    )   external 
        view 
        onlyLawyer()
        returns (bytes32) 
    {
        return keccak256(
            abi.encode(
                _payer, 
                _receiver, 
                _requiredAmount
            )
        );
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
        address payable _receiver,
        uint _requiredAmount,
        bytes32 _escrowId
    ) 
        external 
        override
        onlyLawyer() 
        inState(_escrowId, State.INACTIVE) 
    {
        plans[_escrowId] = Escrow(
             _planName,
            _payer,
            _receiver,
            _requiredAmount,
            _escrowId,
            State.PENDING
            );
        
        // event emitted
        emit EscrowPlanCreated(
            _planName, 
            _escrowId, 
            _payer, 
            _receiver, 
            _requiredAmount, 
            State.PENDING
        );
    }
    
    /**
    * @notice deposit Ether functionality, only payer can execute this function
    * 
    * @param _escrowId required plan id for deposit ether
    */
    function depositEther(bytes32 _escrowId) 
        external 
        override
        payable 
        inState(_escrowId, State.PENDING) 
    {
        require(msg.sender == plans[_escrowId].payer, "Only payer!");
        require(
            msg.value >= plans[_escrowId].requiredAmount, 
            'Invalid amount provided!'
        );
        
        if (msg.value > plans[_escrowId].requiredAmount) {
            plans[_escrowId].payer.transfer(
                msg.value - plans[_escrowId].requiredAmount
            );
            
            plans[_escrowId].state = State.ACTIVE;
        }

        plans[_escrowId].state = State.ACTIVE;
        
        // event emitted
        emit EtherDeposited(
            _escrowId, 
            msg.sender, 
            plans[_escrowId].requiredAmount, 
            State.ACTIVE
        );
    }
    
    /**
    * @notice withdraw Ether functionality, only lawyer can execute this function
    * 
    * @param _escrowId required plan id for withdraw ether
    */
    function withdrawEther(bytes32 _escrowId) 
        external 
        override
        onlyLawyer() 
        inState(_escrowId, State.ACTIVE) 
    {
        plans[_escrowId].state = State.CLOSED;
        plans[_escrowId].receiver.transfer(plans[_escrowId].requiredAmount);
        
        // event emitted
        emit EtherWithdrawed(
            _escrowId, 
            plans[_escrowId].receiver, 
            plans[_escrowId].requiredAmount, 
            State.CLOSED
        );
    }

    /**
    * @return contract balance
    */
    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }
}