// SPDX-License_identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/Fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000
    uint256 constant INITIAL_VALUE = 10 ether;
    // uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundme = deploy.run();
        vm.deal(USER, INITIAL_VALUE);
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumDollarisFive() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        // console.log(fundme.i_owner());
        // console.log(msg.sender);
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        console.log(fundme.getVersion());
        assertEq(fundme.getVersion(), 4);
    }

    function testfundFails() public {
        vm.expectRevert(); //next line should revert
        fundme.fund();
    }

    function testUpdatedAmountFunded() public {
        vm.prank(USER); //the next Tx will be sent by USER
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFunder() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;

    }

    function testOnlyOwnercanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawwithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        //Act
        // uint256 startGas = gasleft();
        // vm.txGasPrice(GAS_PRICE);

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        // uint256 endGas = gasleft();
        // console.log(startGas, "startGas");
        // console.log(endGas, "EndGas");

        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance =  address(fundme).balance;

        console.log(startingOwnerBalance); // 79228162514264337593543950335
        console.log(startingFundmeBalance); // 100000000000000000
        console.log(endingOwnerBalance); // 79228162514364337593543950335
        console.log(endingFundmeBalance); // 0

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerBalance+startingFundmeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance =  address(fundme).balance;

        console.log(startingOwnerBalance); // 79228162514264337593543950335
        console.log(startingFundmeBalance); // 100000000000000000
        console.log(endingOwnerBalance); // 79228162514364337593543950335
        console.log(endingFundmeBalance); // 0

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerBalance+startingFundmeBalance, endingOwnerBalance);
    }


    function testCheaperWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        //Act
        vm.startPrank(fundme.getOwner());
        fundme.cheaperwithdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance =  address(fundme).balance;

        console.log(startingOwnerBalance); // 79228162514264337593543950335
        console.log(startingFundmeBalance); // 100000000000000000
        console.log(endingOwnerBalance); // 79228162514364337593543950335
        console.log(endingFundmeBalance); // 0

        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerBalance+startingFundmeBalance, endingOwnerBalance);
    }
}

// fork-url: test in a simulated real environment
// forge test -vvv --fork-url $SEPOLIA_RPC_URL

// coverage - it shows how many percentage of our code is tested
// forge coverage --fork-url $SEPOLIA_RPC_URL
