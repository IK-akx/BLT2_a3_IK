// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/task5/PriceDependentVault.sol";
import "../../src/task5/MockAggregator.sol";

contract PriceFeedTest is Test {
    PriceDependentVault vault;
    MockAggregator mock;

    address user = address(1);

        function setUp() public {
        vm.deal(user, 10 ether);

        mock = new MockAggregator(2000e8, 8);

        vault = new PriceDependentVault(
            address(mock),
            1500e18,
            1 hours
        );
    }

    function testDeposit() public {
        vm.prank(user);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balances(user), 1 ether);
    }

    function testWithdrawWorksWhenPriceHigh() public {
        vm.startPrank(user);
        vault.deposit{value: 1 ether}();
        vault.withdraw(1 ether);
        vm.stopPrank();
    }

    function testWithdrawRevertsWhenPriceLow() public {
        mock.setPrice(1000e8);

        vm.startPrank(user);
        vault.deposit{value: 1 ether}();

        vm.expectRevert();
        vault.withdraw(1 ether);
        vm.stopPrank();
    }

    function testStalePriceReverts() public {
        vm.startPrank(user);
        vault.deposit{value: 1 ether}();
        vm.stopPrank();

        vm.warp(3 hours);

        vm.prank(user);
        vm.expectRevert();
        vault.withdraw(1 ether);
    }

    function testUsdValueCalculation() public view {
        uint256 usd = vault.getUsdValue(1 ether);

        assertEq(usd, 2000e18);
    }
}