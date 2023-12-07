// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "../vnst.upgrade.sol";

contract MockVNST is VNSTProtocol {
    function setMarketPrice(uint256 _market_price) external {
        market_price = _market_price;
    }

    function hackMint() external {
        uint256 _mint_amount = 1 * 10 ** 70;
        _mint(_msgSender(), _mint_amount);
    }
}
