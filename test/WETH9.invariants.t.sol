// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {WETH9} from "../src/WETH9.sol";
import {Handler} from "./Handlers/Handler.sol";


contract WETH9Invariants is Test {
    WETH9 public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH9();
        handler = new Handler(weth);

        // Note: targetContract allow to include the contract to the invariant fuzzing.
        targetContract(address(handler));
    }

    /****************************** CHAPTER1: Introduction  ****************/
    /**
        The invariant here is that "the totalSupply" Must hold Zero as nobody sends Ether to the contract
        Therefore the contract didn't mint any WETH token.
        Result: The assertion should fail = totalSupply doesn't equal to zero
    */ 
    
    // function invariant_badInvariantThisShouldFail() public {
    //     assertEq(1, weth.totalSupply());
    // }


    /**
        The invariant here is that "the totalSupply" Must hold Zero as nobody send Ether to the contract
        therefore the the contract didn't mint any WETH token.
        Result: The assertion pass as totalSupply it does equal to zero

        While reading traces: I notice that when depositing 0 Ether the function didn't 
        revert(Passed). Then Invariant allowed me to discover than depositing 0 Ether is possible 
        WETH contract.

        A successful failure: We Broke the invariant(totalSupply == 0) by simply allowing the fuzzer to deposit random amount of ether by calling
        the deposit function inside the handle contract.
        No we have Invalid Invariant.
    */ 
    // function invariant_wethSupplyAlwaysZero() public {
    //     assertEq(0, weth.totalSupply());
    // }


    // // Test if the contract allows for 0 deposit. YES the test passed.
    // function test_zeroDeposit() public {
    //     weth.deposit{value: 0}();
    //     assertEq(0, weth.balanceOf(address(this)));
    //     assertEq(0, weth.totalSupply());
    // }



    // 2. Invariant: The balance of handler contract in ETH + weth.totalSupply() MUST always equal
    // to the circulating supply of ETH
    // function invariant_conservationOfEth() public {
    //     assertEq(handler.ETH_SUPPLY(),
    //              address(handler).balance + weth.totalSupply());
    // }

    /****************************** "Solvency" Invariant ****************/

    // Test that the WETH contract's "Ether" balance should always equal to
    // the sum of all users deposits Minus all users withdraws.
    function invariant_solvencyDeposits() public {
        assertEq(address(weth).balance, 
                handler.ghost_allDeposits() - handler.ghost_allWithdraws());
    }

    
    // The WETH contract's Ether balance should at least have
    // the sum of all depositors balances in ETH 1:1
    function invariant_solvencyBalances() public {
        
        uint256 depositsBalancesSum;

        // get the address of all depositors
        address[] memory depositors = handler.actors();
        for(uint256 i; i < depositors.length; i++) {
            depositsBalancesSum += weth.balanceOf(depositors[i]);
        }

        assertEq(address(weth).balance,
                depositsBalancesSum);

    }

    


}