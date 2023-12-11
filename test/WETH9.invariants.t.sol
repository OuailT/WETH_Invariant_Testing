pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {WETH9} from "../src/WETH9.sol";


contract WETH9Invariants is Test {
    WETH9 public weth;

    function setUp() public {
        weth = new WETH9();
    }

    /****************************** CHAPTER1: Introduction  ****************/
    /**
        The invariant here is that "the totalSupply" Must hold Zero as nobody send Ether to it
        because the the contract didn't mint any WETH token.
        Result: The assertion should fail = totalSupply doesn't equal to zero
    */ 
    
    function invariant_badInvariantThisShouldFail() public {
        assertEq(1, weth.totalSupply());
    }


    /**
        The invariant here is that "the totalSupply" Must hold Zero as nobody send Ether to it
        because the the contract didn't mint any WETH token.
        Result: The assertion pass as totalSupply it does equal to zero

        While reading traces: I notice that when depositing 0 Ether the function didn't 
        revert. Then Invariant allowed me to discover than depositing 0 Ether is possible 
        WETH contract.
    */ 
    function invariant_wethSupplyAlwaysZero() public {
        assertEq(0, weth.totalSupply());
    }


    // Test if the contract allows for 0 deposit.
    function test_zeroDeposit() public {
        weth.deposit{value: 0}();
        assertEq(0, weth.balanceOf(address(this)));
        assertEq(0, weth.totalSupply());
    }


    /****************************** CHAPTER2: Handler  ****************/
    


}