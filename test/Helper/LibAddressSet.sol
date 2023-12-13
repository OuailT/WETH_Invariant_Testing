// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// Lib that allow me to set a new address in into an arrary
// Keep track of each address if it's saved or not.
// State variable: Struct and mapping 
// Function to check of addrs array contains an add (true of false)
// Function to count how many address address contains

    struct setAddress {
        address[] addrs;
        mapping(address => bool) isSaved;
    }

library LibAddressSet {

    function add(setAddress storage s, address addr) internal {
        // set address and bool
        if(!s.isSaved[addr]) {
            s.addrs.push(addr);
            s.isSaved[addr] = true;
        }
        
    }


    // Check if address array contains an adress
    function contains(setAddress storage s, address addr) internal view returns(bool) {
        return s.isSaved[addr];
    }


    // Check the number of address that addrs contains
    function countAddr(setAddress storage s) internal view returns(uint256) {
        return s.addrs.length;
    }


    function reduce(setAddress storage s, 
                    uint256 acc,
                    function(uint256, address) external returns(uint256) func 
                    ) internal returns (uint256)
                {
                for(uint i; i < s.addrs.length; i++) {
                    acc = func(acc, s.addrs[i]);
                }
                return acc;
            }

    
    function forEach(setAddress storage s, 
                     function(address) external func)
                     internal  {
                       for(uint256 i; i < s.addrs.length; i++) {
                            func(s.addrs[i]);
                       } 
    }

}