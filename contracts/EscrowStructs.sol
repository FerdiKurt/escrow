// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

contract EscrowStructs {
    enum State { PENDING, ACTIVE, CLOSED }

    struct Escrow {
        string planName;
        address payable payer;
        address payable recipient;
        uint requiredAmount;
        uint escrowId;
        uint timestamp;
        State state;
    }
}