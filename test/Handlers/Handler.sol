pragma solidity ^0.8.13;


import "forge-std/Test.sol";
import "../../src/WETH9.sol";

contract Handler is Test {

    WETH9 public weth;

    uint256 public constant ETH_SUPPLY = 120_500_000;

    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(this), ETH_SUPPLY);
    }

    /**
           We going to use "bound method" to ensure that Invariant test doens't revert, when the fuzzer 
           input an amount of ether that the handler contract doesn't have when calling deposit() function
           Bond is mathemtical function for wrapping inputs of fuzz tests into a certain rage
     */
    // Test if deposit Ether that handeler contract hold can break out invariant()
    function deposit(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        weth.deposit{value: amount}();
    } 


    // Allow to convert/unrapped WETH to ETH
    // Test if Withdrawing ETH from WETH can break our invariant
    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(address(this)));
        weth.withdraw(amount);
    }


    // Test if sending ether directly to the contract can break our invariant
    function sendETHFallBack(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        (bool succ, ) = address(weth).call{value: amount}("");
        require(succ, "Direct Transfer fail");
    }

    receive() external payable {}


}