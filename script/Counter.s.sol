// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import "frax-std/BaseScript.sol";
import { console } from "frax-std/FraxTest.sol";
import { Counter } from "src/Counter.sol";

contract DeployContract is BaseScript {
    function run() public broadcaster {
        _deploy();
    }
}

function _deploy() {
    address instance = address(new Counter());
    console.log("Contract deployed @", instance);
}
