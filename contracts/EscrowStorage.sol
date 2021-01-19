// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

import './EscrowStructs.sol';

contract EscrowStorage is EscrowStructs {
        // state variables also we can call them storage variables
    address public lawyer;
    mapping(uint => uint) public required;
    mapping(uint => uint) public fulfilled;
    mapping(uint => Escrow) public plans;
}