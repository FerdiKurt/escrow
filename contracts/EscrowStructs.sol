// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

contract EscrowStructs {
    // enum for state control
    enum State { INACTIVE, PENDING, ACTIVE, CLOSED }

    struct Escrow {
        string planName;
        address payable payer;
        address payable receiver;
        uint requiredAmount;
        bytes32 escrowId;
        State state;
    }
}