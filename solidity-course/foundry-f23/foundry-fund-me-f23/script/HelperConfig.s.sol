// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Deploy mocks when we are on a local anvil chain 
// 2. keep track of address across dirfferent chains `sepoloa ETH/USD` ` Mainnet ETH/USD`

// This contract will help  us work with different chains as well as our local foundry anvil chain - so we are not having to hard code an addresses 

import {Script} from "forge-std/Script.sol";
import{MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// if we are on a local anvil, we deploy mocks
// otherwise grab the existing address from the live network

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

// see MAGIC NUMBER
    uint8 public constant DECIMALS = 8;
    int256  public constant INTIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed; // ETH/USD price feed address
    }

    constructor() { // constructor that will set what network we are working on if we are not on sepolia then it will switch to our local anvil chain

        if (block.chainid == 11155111) { // this is the sepolia networks chain id 
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) { // eth mainnet chain id
            activeNetworkConfig = getMainnetEthConfig();
        }         
        else {
            activeNetworkConfig = getOrCreaateAnvilEthConfig();
        }
    }
    
    // function that will return a configuration from the sepolia network - this will be the pricefeed - so it will give us the price of eth to USD on the Sepolia network 
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) { // we use the memory keyword because `NetworkConfig` as we are passing a struct
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }   
    // this function does the same as the above but gives the price from eth main net
    function getMainnetEthConfig() public pure returns(NetworkConfig memory) { 
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }  
    // we can use the above function to deploy on any network so all we have to do is add an additional `Networkconfig` and it will work - so go on alchemy dashboard create another app for another network (polygon, Starknet etc) take the HTTPS API address coppy and paste it into our .env file MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/2UZA4zxAnu5iaKpyjVpw2QWx3m-yiZzt` (keep the `=` with no gaps) - source .env 


// Deploy the mocks (dummie contract) the functions above get their pricefeeds from their own networks `sepolia, mainnet etc` the below is mock price feed arrgegator so we have imported a `MockV3Aggregator` pricefeed contract as live fees dont exists on a local network so this mock contract has all the code of a price feed 
// return the mock address 
    function getOrCreaateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) { // the address(0) is a way to get th defualt address or the zero address
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        
       // MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8); // MAGIC NUMBERS - looking at these numbers 8, 2000e8 we may not know what they are - unless we click on MockV3Aggregator` and it will take us to the constructor `constructor(uint8 _decimals, int256 _initialAnswer)` now we can see what these are - if we have alot of code we need to do this for it can get confusing - most developers will turn these MAGIC NUMBERS into `constant` variables at the top of our code 
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, 
            INTIAL_PRICE
         );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) 
        });

        return anvilConfig;


    }



}
