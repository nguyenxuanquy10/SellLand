// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract tokenERC20 is ERC20 {
    constructor() ERC20("DevToken", "KaBa") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}
