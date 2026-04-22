// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../../src/task1/GameItems.sol";

contract GoodReceiver is ERC1155Holder {}

contract BadReceiver {
    // does not implement ERC1155Receiver
}

contract GameItemsTest is Test {
    GameItems internal gameItems;

    address internal OWNER = address(1);
    address internal alice = address(2);
    address internal bob = address(3);

    string internal constant BASE_URI = "ipfs://game-items/{id}.json";

    uint256 internal constant GOLD = 1;
    uint256 internal constant WOOD = 2;
    uint256 internal constant IRON = 3;
    uint256 internal constant LEGENDARY_SWORD = 1001;
    uint256 internal constant DRAGON_SHIELD = 1002;

    function setUp() public {
        gameItems = new GameItems(BASE_URI, OWNER);
    }

    function testConstructorSetsBaseUri() public view {
        assertEq(gameItems.uri(0), BASE_URI);
    }

    function testOwnerCanMintFungibleToken() public {
        vm.prank(OWNER);
        gameItems.mint(alice, GOLD, 500, "");

        assertEq(gameItems.balanceOf(alice, GOLD), 500);
    }

    function testOwnerCanMintNftAmountOne() public {
        vm.prank(OWNER);
        gameItems.mint(alice, LEGENDARY_SWORD, 1, "");

        assertEq(gameItems.balanceOf(alice, LEGENDARY_SWORD), 1);
    }

    function testMintNftRevertsIfAmountGreaterThanOne() public {
        vm.prank(OWNER);
        vm.expectRevert(GameItems.GameItems__InvalidNFTOutput.selector);
        gameItems.mint(alice, DRAGON_SHIELD, 2, "");
    }

    function testMintBatchWorksCorrectly() public {
        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);

        ids[0] = GOLD;
        ids[1] = WOOD;
        ids[2] = IRON;

        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        vm.prank(OWNER);
        gameItems.mintBatch(alice, ids, amounts, "");

        assertEq(gameItems.balanceOf(alice, GOLD), 100);
        assertEq(gameItems.balanceOf(alice, WOOD), 200);
        assertEq(gameItems.balanceOf(alice, IRON), 300);
    }

    function testSafeTransferFromWorks() public {
        vm.prank(OWNER);
        gameItems.mint(alice, GOLD, 150, "");

        vm.prank(alice);
        gameItems.safeTransferFrom(alice, bob, GOLD, 50, "");

        assertEq(gameItems.balanceOf(alice, GOLD), 100);
        assertEq(gameItems.balanceOf(bob, GOLD), 50);
    }

    function testSafeBatchTransferFromWorks() public {
        uint256[] memory ids = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);

        ids[0] = GOLD;
        ids[1] = WOOD;
        ids[2] = IRON;

        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        vm.prank(OWNER);
        gameItems.mintBatch(alice, ids, amounts, "");

        uint256[] memory transferAmounts = new uint256[](3);
        transferAmounts[0] = 10;
        transferAmounts[1] = 20;
        transferAmounts[2] = 30;

        vm.prank(alice);
        gameItems.safeBatchTransferFrom(alice, bob, ids, transferAmounts, "");

        assertEq(gameItems.balanceOf(alice, GOLD), 90);
        assertEq(gameItems.balanceOf(alice, WOOD), 180);
        assertEq(gameItems.balanceOf(alice, IRON), 270);

        assertEq(gameItems.balanceOf(bob, GOLD), 10);
        assertEq(gameItems.balanceOf(bob, WOOD), 20);
        assertEq(gameItems.balanceOf(bob, IRON), 30);
    }

    function testCraftLegendarySwordBurnsResourcesAndMintsNft() public {
        vm.startPrank(OWNER);
        gameItems.mint(alice, GOLD, 100, "");
        gameItems.mint(alice, IRON, 50, "");
        vm.stopPrank();

        vm.prank(alice);
        gameItems.craft(1);

        assertEq(gameItems.balanceOf(alice, GOLD), 0);
        assertEq(gameItems.balanceOf(alice, IRON), 0);
        assertEq(gameItems.balanceOf(alice, LEGENDARY_SWORD), 1);
    }

    function testCraftDragonShieldBurnsResourcesAndMintsNft() public {
        vm.startPrank(OWNER);
        gameItems.mint(alice, GOLD, 20, "");
        gameItems.mint(alice, WOOD, 80, "");
        gameItems.mint(alice, IRON, 40, "");
        vm.stopPrank();

        vm.prank(alice);
        gameItems.craft(2);

        assertEq(gameItems.balanceOf(alice, GOLD), 0);
        assertEq(gameItems.balanceOf(alice, WOOD), 0);
        assertEq(gameItems.balanceOf(alice, IRON), 0);
        assertEq(gameItems.balanceOf(alice, DRAGON_SHIELD), 1);
    }

    function testCraftRevertsIfInsufficientResources() public {
        vm.startPrank(OWNER);
        gameItems.mint(alice, GOLD, 99, "");
        gameItems.mint(alice, IRON, 50, "");
        vm.stopPrank();

        vm.prank(alice);
        vm.expectRevert(GameItems.GameItems__InsufficientResources.selector);
        gameItems.craft(1);
    }

    function testCraftRevertsForInvalidRecipe() public {
        vm.prank(alice);
        vm.expectRevert(GameItems.GameItems__InvalidRecipe.selector);
        gameItems.craft(999);
    }

    function testSafeTransferToValidReceiverContractWorks() public {
        GoodReceiver receiver = new GoodReceiver();

        vm.prank(OWNER);
        gameItems.mint(alice, GOLD, 100, "");

        vm.prank(alice);
        gameItems.safeTransferFrom(alice, address(receiver), GOLD, 25, "");

        assertEq(gameItems.balanceOf(address(receiver), GOLD), 25);
    }

    function testSafeTransferToInvalidReceiverContractReverts() public {
        BadReceiver receiver = new BadReceiver();

        vm.prank(OWNER);
        gameItems.mint(alice, GOLD, 100, "");

        vm.prank(alice);
        vm.expectRevert();
        gameItems.safeTransferFrom(alice, address(receiver), GOLD, 25, "");
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(alice);
        vm.expectRevert();
        gameItems.mint(alice, GOLD, 100, "");
    }

    function testSetBaseUriWorks() public {
        string memory newUri = "ipfs://updated/{id}.json";

        vm.prank(OWNER);
        gameItems.setBaseURI(newUri);

        assertEq(gameItems.uri(0), newUri);
    }
}