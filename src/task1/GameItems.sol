// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract GameItems is ERC1155, Ownable {
    // Fungible resources
    uint256 public constant GOLD = 1;
    uint256 public constant WOOD = 2;
    uint256 public constant IRON = 3;

    // NFT items (minted one-by-one)
    uint256 public constant LEGENDARY_SWORD = 1001;
    uint256 public constant DRAGON_SHIELD = 1002;

    string private s_baseMetadataURI;

    struct Recipe {
        uint256 goldRequired;
        uint256 woodRequired;
        uint256 ironRequired;
        uint256 outputTokenId;
        bool exists;
    }

    mapping(uint256 => Recipe) private s_recipes;

    event ItemMinted(address indexed to, uint256 indexed id, uint256 amount);
    event BatchMinted(address indexed to, uint256[] ids, uint256[] amounts);
    event RecipeSet(
        uint256 indexed recipeId,
        uint256 goldRequired,
        uint256 woodRequired,
        uint256 ironRequired,
        uint256 outputTokenId
    );
    event Crafted(address indexed user, uint256 indexed recipeId, uint256 indexed outputTokenId);

    error GameItems__InvalidAddress();
    error GameItems__InvalidRecipe();
    error GameItems__InsufficientResources();
    error GameItems__InvalidNFTOutput();
    error GameItems__ZeroAmount();

    constructor(
        string memory baseMetadataURI,
        address initialOwner
    ) ERC1155(baseMetadataURI) Ownable(initialOwner) {
        if (initialOwner == address(0)) {
            revert GameItems__InvalidAddress();
        }

        s_baseMetadataURI = baseMetadataURI;

        // Recipe 1 -> Legendary Sword
        s_recipes[1] = Recipe({
            goldRequired: 100,
            woodRequired: 0,
            ironRequired: 50,
            outputTokenId: LEGENDARY_SWORD,
            exists: true
        });

        emit RecipeSet(1, 100, 0, 50, LEGENDARY_SWORD);

        // Recipe 2 -> Dragon Shield
        s_recipes[2] = Recipe({
            goldRequired: 20,
            woodRequired: 80,
            ironRequired: 40,
            outputTokenId: DRAGON_SHIELD,
            exists: true
        });

        emit RecipeSet(2, 20, 80, 40, DRAGON_SHIELD);
    }

   
    function mint(address to, uint256 id, uint256 amount, bytes memory data) external onlyOwner {
        if (to == address(0)) {
            revert GameItems__InvalidAddress();
        }
        if (amount == 0) {
            revert GameItems__ZeroAmount();
        }

        // NFT items should only be minted in amount 1
        if (_isNft(id) && amount != 1) {
            revert GameItems__InvalidNFTOutput();
        }

        _mint(to, id, amount, data);
        emit ItemMinted(to, id, amount);
    }

    
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyOwner {
        if (to == address(0)) {
            revert GameItems__InvalidAddress();
        }

        uint256 length = ids.length;
        if (length != amounts.length) {
            revert GameItems__InvalidRecipe();
        }

        for (uint256 i = 0; i < length; i++) {
            if (amounts[i] == 0) {
                revert GameItems__ZeroAmount();
            }
            if (_isNft(ids[i]) && amounts[i] != 1) {
                revert GameItems__InvalidNFTOutput();
            }
        }

        _mintBatch(to, ids, amounts, data);
        emit BatchMinted(to, ids, amounts);
    }

    function craft(uint256 recipeId) external {
        Recipe memory recipe = s_recipes[recipeId];
        if (!recipe.exists) {
            revert GameItems__InvalidRecipe();
        }

        if (
            balanceOf(msg.sender, GOLD) < recipe.goldRequired ||
            balanceOf(msg.sender, WOOD) < recipe.woodRequired ||
            balanceOf(msg.sender, IRON) < recipe.ironRequired
        ) {
            revert GameItems__InsufficientResources();
        }

        if (recipe.goldRequired > 0) {
            _burn(msg.sender, GOLD, recipe.goldRequired);
        }
        if (recipe.woodRequired > 0) {
            _burn(msg.sender, WOOD, recipe.woodRequired);
        }
        if (recipe.ironRequired > 0) {
            _burn(msg.sender, IRON, recipe.ironRequired);
        }

        _mint(msg.sender, recipe.outputTokenId, 1, "");
        emit Crafted(msg.sender, recipeId, recipe.outputTokenId);
    }

    
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        s_baseMetadataURI = newBaseURI;
    }

    
    function uri(uint256) public view override returns (string memory) {
        return s_baseMetadataURI;
    }

    function getRecipe(
        uint256 recipeId
    )
        external
        view
        returns (
            uint256 goldRequired,
            uint256 woodRequired,
            uint256 ironRequired,
            uint256 outputTokenId,
            bool exists
        )
    {
        Recipe memory recipe = s_recipes[recipeId];
        return (
            recipe.goldRequired,
            recipe.woodRequired,
            recipe.ironRequired,
            recipe.outputTokenId,
            recipe.exists
        );
    }

    function _isNft(uint256 id) internal pure returns (bool) {
        return id == LEGENDARY_SWORD || id == DRAGON_SHIELD;
    }
}