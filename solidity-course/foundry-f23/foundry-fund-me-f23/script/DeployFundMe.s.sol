// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {

        HelperConfig helperConfig = new HelperConfig(); // this will create a new contract called `new  HelperConfig` this will allow us to test it first before we delpoy it on a real network as it costs gas so anything before `vm.startBroadcast` will not be sent as a real transaction ---- anything after `vm.Broadcast` will be sent as a real transaction and cost gas


        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }

}