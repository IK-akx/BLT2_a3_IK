// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/task2/Vault.sol";
import "../../src/task2/MockERC20.sol";

contract VaultTest is Test {
    Vault internal vault;
    MockERC20 internal token;

    address internal OWNER = address(1);
    address internal alice = address(2);
    address internal bob = address(3);

    function setUp() public {
        token = new MockERC20();

        vault = new Vault(
            IERC20(address(token)),
            "Vault Share",
            "vSHARE",
            OWNER
        );

        // give users tokens
        token.mint(alice, 1000 ether);
        token.mint(bob, 1000 ether);
        token.mint(OWNER, 1000 ether);
    }

    function testDeposit() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);

        vault.deposit(100 ether, alice);

        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 100 ether);
        assertEq(vault.totalAssets(), 100 ether);
    }

    function testWithdraw() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);

        vault.withdraw(50 ether, alice, alice);
        vm.stopPrank();

        assertEq(token.balanceOf(alice), 950 ether);
    }

    function testMintShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);

        vault.mint(100 ether, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 100 ether);
    }

    function testRedeemShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);

        vault.redeem(50 ether, alice, alice);
        vm.stopPrank();

        assertEq(token.balanceOf(alice), 950 ether);
    }

    function testHarvestIncreasesShareValue() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);
        vm.stopPrank();

        vm.startPrank(OWNER);
        token.approve(address(vault), 100 ether);
        vault.harvest(100 ether);
        vm.stopPrank();

        uint256 assets = vault.convertToAssets(100 ether);

        assertApproxEqAbs(assets, 200 ether, 1);
    }

    function testConvertToShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);
        vm.stopPrank();

        vm.startPrank(OWNER);
        token.approve(address(vault), 100 ether);
        vault.harvest(100 ether);
        vm.stopPrank();

        uint256 shares = vault.convertToShares(100 ether);

        assertEq(shares, 50 ether);
    }

    function testConvertToAssets() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);
        vm.stopPrank();

        vm.startPrank(OWNER);
        token.approve(address(vault), 100 ether);
        vault.harvest(100 ether);
        vm.stopPrank();

        uint256 assets = vault.convertToAssets(50 ether);

        assertApproxEqAbs(assets, 100 ether, 1);
    }

    function testMultipleUsersFairShare() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);
        vm.stopPrank();

        vm.startPrank(bob);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, bob);
        vm.stopPrank();

        vm.startPrank(OWNER);
        token.approve(address(vault), 200 ether);
        vault.harvest(200 ether);
        vm.stopPrank();

        uint256 aliceAssets = vault.convertToAssets(vault.balanceOf(alice));
        uint256 bobAssets = vault.convertToAssets(vault.balanceOf(bob));

        assertApproxEqAbs(aliceAssets, 200 ether, 1);
        assertApproxEqAbs(bobAssets, 200 ether, 1);
    }
}