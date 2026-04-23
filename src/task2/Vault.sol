// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Vault is ERC4626, Ownable {
    event Harvest(uint256 amountAdded);

    constructor(
        IERC20 asset_,
        string memory name_,
        string memory symbol_,
        address owner_
    ) ERC20(name_, symbol_) ERC4626(asset_) Ownable(owner_) {}

    
    function harvest(uint256 amount) external onlyOwner {
        require(amount > 0, "zero");

        IERC20(asset()).transferFrom(msg.sender, address(this), amount);

        emit Harvest(amount);
    }
}