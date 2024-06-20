// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*We want to test that our that our contracts are doing what we want them to do - to do this we can put them through `test` contracts In Foundry, a smart contract development framework for Ethereum, assertEq is a function used in tests to assert that two values are equal. Foundry uses the Forge testing framework, which includes various assertion functions to help verify the behavior of smart contracts.*/ 

import {Test, console} from "forge-std/Test.sol"; // file that helps us test out contract, it inherits all the functionality of the `Test.sol` contract
import {FundMe} from "../../src/FundMe.sol"; // we want to test that our `Fundme.sol` contract is doing what it is meant to do - so we test it in a .t.sol file and we need to import it
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test { // inherting from the imported test.sol

    FundMe fundMe; // state variable called `fundMe` that inherits all the functionality of `FundMe.sol`

    address USER = makeAddr("user"); // another cheatcode `makeAddr` when we pass in a name it will  give is an address

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether; // our fake USER needs fake money
    uint256 constant GAS_PRICE = 1; // simulating the gas price in our 


    function setUp() external { // the `setUp` function is  the frist thing that we do and it is in here that we deploy our contract that is be tested The setUp function initializes the FundMe contract before each test
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // 
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // here we are giving our fake USER the fake money

    }

    function testMinimumDollarIsFive() public view { // we can pick the functions from the FundMe contract we want ot test
    // when tesing we must use the `test` in front of the function name
        assertEq(fundMe.MINIMUM_USD(), 5e18); // This test specifically checks that the  `uint256 public constant MINIMUM_USD = 5 * 10 ** 18;` in the FundMe contract is equal to 5e18

    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.getOwner()); // when looking for why our functions fail we can use `console.log` - it will print out to the termainl - in this case the address of the `fundMe` contract
        // console.log(msg.sender); // and in this case the address of the msg.sender who is calling gh contract is nott the owner so this will show in the terminal reprot
        
        assertEq(fundMe.getOwner(), msg.sender);
    } //This test checks that the i_owner variable in the FundMe contract is set to the 
 // address of the test contract (i.e., address(this)).
/*By using assertEq, you can easily write tests that check whether the actual values in your smart 
contract match the expected values, helping you ensure the correctness of your code.*/

    // when we test this function it will fail because the address in the 

    /*function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version(); does not exist */
    

    function testPriceFeedVersionIsAccurate() public view {
    uint256 version = fundMe.getVersion();
   
    assertEq(version, 4); // Ensure the expected value matches the actual value
}

// our fund function requires we send enough funds otherwise it will revert wih an error 
// `require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");`...
// this tests to make sure that happens so we are expecting it to revert when no funds are sent 
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // we use the cheatcode `epectRevert` when we want something to fail, when we expect it fail and revert 
        fundMe.fund(); // this will fail as we are sending 0 as we are not passing any value and the minimum is 5 USD in our fund function  - so it will pass the test becuse it has failed
    }

    function testFundUpdatesFundeddataStructure() public {
        vm.prank(USER); // the next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // magic number 
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); 
        assertEq(amountFunded, SEND_VALUE);  // SEND_VALUE magic number now a constant above
        }
    
    function testAddsFunderToArrayOFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE} ();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }  

    modifier funded() {  // if we have a lote of code to test using vm.prank - we can use a modifier now all we have to do is use the `funded` keyword on the function below  
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    // test the onlyOwner modifier is working correctly on the withdraw function so only the owner can call the withdraw function with the modifier keyword

    function testOnlyOwnerCanWithdraw() public funded { // here we are using the modifier keyword `funded`
        // vm.prank(USER); // not needed now as we the modifier 
        // fundMe.fund{value: SEND_VALUE} ();
        vm.expectRevert(); // this wont expect the next line to fail as it ignores its own `vm.` cheatcodes and only does transaction code   
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // this gets the owners starting balance
        uint256 startingFundMebalance = address(fundMe).balance; // this gets the actual balance of the fundMe contract 

        // Act
        uint256 gasStart = gasleft(); // (Start we have 1000 gas)this gasleft is a biult in function in solidity and tells us how much gas is left in our tc call 
        vm.txGasPrice(GAS_PRICE); //  we can use to get accurate gas usage for a transaction as this is not a real tx
        vm.prank(fundMe.getOwner()); // this function cost / used 200 gas 
        fundMe.withdraw();// this should of spent gas 

        uint256 gasEnd = gasleft(); // here we have 800 gas left 
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // `tx.price` is another built in function in solidity that tells us th current gas price
        console.log(gasUsed); // this will give us the totl used for this function on the terminal 

        // Assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMebalance + startingOwnerBalance, endingOwnerBalance);

        }

        function testWithdrawFromMultipleFunders() public funded{ // test with multiple funders 
            // Arrange
            // Notice the `unit160`
            uint160 numberOfFunders = 10; // as these are going to be addresses and we cannot use cast explicity from address to unit256 - uint160 has the same bytes as an address
            uint160 statingFunderIndex = 1; // dont start for mthe zero address as it will revert start at 1
            
            for(uint160 i = statingFunderIndex; i < numberOfFunders; i++) {

                // vm.prank - creates a new address
                // vm.deal - funds the new address
                // we could use the above but foundry comes with `hoax` that does both so sets up a prank with some ether, if no blance is specified it will be set to 2^128 wei
                hoax(address(i), SEND_VALUE); // statring with a blank address which we will send value which is `uint256 constant SEND_VALUE = 0.1 ether;`
                fundMe.fund{value: SEND_VALUE}();
           }

            uint256 startingOwnerbalance = fundMe.getOwner().balance;
            uint256 startingFundMebalance = address(fundMe).balance;

            // Act
            // the start and stopPrank is the same as start and stopBroadcasr 
            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
            vm.stopPrank();

            // Assert
            assert(address(fundMe).balance == 0);
            assert(startingFundMebalance + startingOwnerbalance == fundMe.getOwner().balance);




        }
    }





   

