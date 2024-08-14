// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title VNST Stable Coin Smart Contract
/// @author Nami Innovation
/// @notice VNST Stable Coin and VMM
contract VNSTProxy is
    Initializable,
    ERC20Upgradeable,
    ERC20PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlEnumerableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    /// @notice USDT (u)
    /// @notice VNST (v)
    /// @notice R-center = v / u
    /// @notice Q-Support above
    /// @notice Q-Support bellow
    /// @notice R-Support above
    /// @notice R-Support bellow
    /// @notice k constant = u * v
    /// @notice operation_pool
    IERC20 public usdt;
    uint256 public usdt_pool;
    uint256 public vnst_pool;
    uint256 public market_price;
    uint256 public redeem_covered_amount;
    uint256 public mint_covered_amount;
    uint256 public redeem_covered_price;
    uint256 public mint_covered_price;
    uint256 public k;
    uint256 public min_redeem_limit;
    uint256 public min_mint_limit;
    uint256 public max_mint_limit;
    uint256 public operation_pool;
    uint256 public redeem_fee;

    uint256 internal constant _rate_decimal = 1000000;

    /// @param address_usdt address of usdt stable coin
    function initialize(address address_usdt) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MODERATOR_ROLE, _msgSender());
        __Ownable_init();

        __ERC20_init("VNST Token", "VNST");

        usdt = IERC20(address_usdt);
        market_price = 25000000000;
        usdt_pool = 30000000 * 10 ** 18;
        vnst_pool = (usdt_pool * market_price) / _rate_decimal;
        redeem_covered_amount = 100000 * 10 ** 18;
        mint_covered_amount = 2500000000 * 10 ** 18;
        redeem_covered_price = 25200000000;
        mint_covered_price = 24900000000;
        k = usdt_pool * vnst_pool;
        min_redeem_limit = 100000 * 10 ** 18;
        min_mint_limit = 5 * 10 ** 18;
        max_mint_limit = 2000 * 10 ** 18;
        operation_pool = 0;
        redeem_fee = 1000;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function addMod(address mod) external onlyOwner {
        grantRole(MODERATOR_ROLE, mod);
    }

    function removeMod(address mod) external onlyOwner {
        revokeRole(MODERATOR_ROLE, mod);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
