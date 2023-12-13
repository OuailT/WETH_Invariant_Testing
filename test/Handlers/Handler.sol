// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;


import "forge-std/Test.sol";
import "../../src/WETH9.sol";
import "../Helper/LibAddressSet.sol";

contract Handler is Test {

    using LibAddressSet for setAddress;

    setAddress internal _actors;
    address internal currentActor;

    WETH9 public weth;

    uint256 public constant ETH_SUPPLY = 120_500_000;
    uint256 public ghost_allDeposits;
    uint256 public ghost_allWithdraws;

    
    constructor(WETH9 _weth) {
        weth = _weth;
        deal(address(this), ETH_SUPPLY);
    }


    // Return address of actor.
    function actors() public view returns(address[] memory) {
        return _actors.addrs;
    }


    // create a modifier that will add the address of a depositor
    modifier createActor() {
        // Since _actors in instance of setAddress using "using" keywords means
        // _actors.add(msg.sender) ==  add(_actors, msg.sender);
        currentActor = msg.sender;
        _actors.add(currentActor);
        _;
    }

    

    /**
           We going to use "bound method" to ensure that Invariant test doens't revert, when the fuzzer 
           input an amount of ether that the handler contract doesn't have when calling deposit() function
           Bond is mathemtical function for wrapping inputs of fuzz tests into a certain rage
     */
    // Test if deposit Ether that handeler contract hold can break out invariant()
    function deposit(uint256 amount) public createActor {
        amount = bound(amount, 0, address(this).balance);
        _send(currentActor, amount);
        vm.prank(currentActor);
        weth.deposit{value: amount}();
        ghost_allDeposits += amount;
    } 


    // Allow to convert/unrapped WETH to ETH
    // Test if Withdrawing ETH from WETH can break our invariant
    function withdraw(uint256 amount) public  {
        // Set the balance of msg.sender within the range they hold
        amount = bound(amount, 0, weth.balanceOf(msg.sender));

        vm.prank(msg.sender);
        weth.withdraw(amount);
        // payback ETH borrowed to address(this)
        _send(address(this), amount);
        vm.stopPrank();

        ghost_allWithdraws += amount;
    }


    // Test if sending ether directly to the contract can break our invariant
    function sendETHFallBack(uint256 amount) public createActor{
        amount = bound(amount, 0, address(this).balance);
        _send(currentActor, amount);
        
        vm.prank(currentActor);
        (bool succ, ) = address(weth).call{value: amount}("");
        require(succ, "Direct Transfer fail");

        ghost_allDeposits += amount;
    }


    receive() external payable {}

    function _send(address to, uint256 amount) public {
         (bool succ, ) = to.call{value: amount}("");
         require(succ, "trx failed");
    }


    function reduceActors(
        uint256 acc,
        function(uint256, address) external returns(uint256) func
    ) public 
      returns(uint256) {
      return _actors.reduce(acc, func);
    }

    function forEachActor(function(address) external func) public {
        return _actors.forEach(func);
    }


}


