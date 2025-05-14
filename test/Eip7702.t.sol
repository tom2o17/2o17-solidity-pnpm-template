// SPDX-License-Identifier: ISC
pragma solidity ^0.8.20;

import "frax-std/FraxTest.sol";
import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test, console2 as console } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";

/// Holds a signed EIP-7702 authorization for an authority account to delegate to an implementation.
struct SignedDelegation {
    // The y-parity of the recovered secp256k1 signature (0 or 1).
    uint8 v;
    // First 32 bytes of the signature.
    bytes32 r;
    // Second 32 bytes of the signature.
    bytes32 s;
    // The current nonce of the authority account at signing time.
    // Used to ensure signature can't be replayed after account nonce changes.
    uint64 nonce;
    // Address of the contract implementation that will be delegated to.
    // Gets encoded into delegation code: 0xef0100 || implementation.
    address implementation;
}

contract Test_EIP_7702 is Test {
    address al;
    uint key_al;
    address batcher;
    address bob = address(0xb0b);
    IERC20 frxUSD = IERC20(0xCAcd6fd266aF91b8AeD52aCCc382b4e165586E29);
    IERC20 lfrax = IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    
    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        ( al, key_al) = makeAddrAndKey("alice");
        batcher = address(new Batcher());
    }
    
    address[] targets;
    uint256[] values;
    bytes[] data;
    function test_EIP_7702() public {
        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(batcher, key_al);
        uint nonce = vm.getNonce(al);
        console.log("nonce: ", nonce);

        
        nonce = vm.getNonce(al);
        console.log("nonce: ", nonce);

        deal(address(lfrax), al, 1e18);
        deal(address(frxUSD), al, 1e18);

        targets.push(address(frxUSD));
        targets.push(address(lfrax));
        values.push(0);
        values.push(0);
        data.push(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(bob),
                uint(69)
            )
        );
        data.push(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(bob),
                uint(69)
            )
        );

        vm.attachDelegation(signedDelegation);

        bytes memory code = address(al).code;
        require(code.length > 0, "no code written to Alice");

        vm.startBroadcast(bob);
        Batcher(al).exec(
            targets,
            values,
            data
        );
        vm.stopBroadcast();

        nonce = vm.getNonce(al);
        console.log("nonce: ", nonce);
    
        console.log(" frx allowance", frxUSD.balanceOf(bob));
        console.log(" frx allowance", lfrax.balanceOf(bob));
    }
}


contract Batcher {
    function exec(
        address[] memory targets, 
        uint256[] memory values, 
        bytes[] memory data
    ) external {
        for (uint i; i < targets.length; ++i) {
            (bool ok, ) = targets[i].call{value: values[i]}(data[i]);
            require(ok);
        }
    }
}