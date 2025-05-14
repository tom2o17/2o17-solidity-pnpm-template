// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import { Vm, VmSafe } from "forge-std/Vm.sol";
import "frax-std/BaseScript.sol";
import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Batcher } from "test/Eip7702.t.sol";

contract EIP7702SimulatedTest is Script {
    address alice;
    uint256 alicePk;
    address bob;

    address[] targets;
    uint256[] values;
    bytes[] data;


    IERC20 frxUSD = IERC20(0xCAcd6fd266aF91b8AeD52aCCc382b4e165586E29);
    IERC20 lfrax = IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    
    // Alice's address and private key (EOA with no initial contract code).
   
    uint256 ALICE_PK = vm.envUint("PK_1");
    address ALICe_ADDRESS = vm.addr(ALICE_PK);
    // Bob's address and private key (Bob will execute transactions on Alice's behalf).
    
    uint256 BOB_PK = vm.envUint("PK_2");
    address BOB_ADDRESS = vm.addr(BOB_PK);
    // Deployer's address and private key (used to deploy contracts).

    // The contract that Alice will delegate execution to.
    Batcher public implementation;


    function run() external {


        targets.push(address(frxUSD));
        targets.push(address(lfrax));
        values.push(0);
        values.push(0);
        data.push(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(BOB_ADDRESS),
                uint(42069)
            )
        );
        data.push(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(BOB_ADDRESS),
                uint(42069)
            )
        );
        implementation = Batcher(0x1Ec51ea2582B3B49967fc7b7036dC21Ac0a6Bc54);


        // Step 2: Bob executes through delegated EOA (Alice now routes to Batcher)
        vm.broadcast(ALICE_PK);
        vm.signAndAttachDelegation(address(implementation), ALICE_PK);
        // Batcher(ALICE_ADDRESS).exec(targets, values, data);
        address(0).call{value: 0}(hex"");
        // vm.stopBroadcast();
    }
}