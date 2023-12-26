// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/math/Math.sol";

// contract VNSTVIC is Ownable, AccessControl, ReentrancyGuard, Pausable, ERC20 {
//     using SafeMath for uint256;
//     using SafeERC20 for IERC20;

//     bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

//     /// @notice USDT (u)
//     /// @notice VNST (v)
//     /// @notice R-center = v / u
//     /// @notice Q-Support above
//     /// @notice Q-Support bellow
//     /// @notice R-Support above
//     /// @notice R-Support bellow
//     /// @notice k constant = u * v
//     /// @notice operation_pool
//     IERC20 public usdt;
//     uint256 public usdt_pool;
//     uint256 public vnst_pool;
//     uint256 public market_price;
//     uint256 public redeem_covered_amount;
//     uint256 public mint_covered_amount;
//     uint256 public redeem_covered_price;
//     uint256 public mint_covered_price;
//     uint256 public k;
//     uint256 public min_redeem_limit;
//     uint256 public min_mint_limit;
//     uint256 public max_mint_limit;
//     uint256 public operation_pool;
//     uint256 public redeem_fee;
//     uint256 public max_redeem_limit;

//     uint24 internal constant _rate_decimal = 1000000;

//     /**
//      * @notice Event
//      */
//     event EMint(
//         address indexed address_mint,
//         uint256 amount_in,
//         uint256 amount_out,
//         uint256 created_at,
//         uint256 market_price
//     );
//     event ERedeem(
//         address indexed address_withdraw,
//         uint256 amount_in,
//         uint256 amount_out,
//         uint256 created_at,
//         uint256 market_price
//     );

//     event EOperationPool(address indexed address_withdraw, uint256 amount, uint256 created_at);

//     constructor() ERC20("VNST Token", "VNST") {
//         Ownable(_msgSender());
//         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
//         _setupRole(MODERATOR_ROLE, _msgSender());

//         usdt = IERC20(0x69d75da9e018f3E624c173358f47fffCdBaB5362);
//         market_price = 25000000000;
//         usdt_pool = 30000000 * 10 ** 18;
//         vnst_pool = (usdt_pool * market_price) / _rate_decimal;
//         redeem_covered_amount = 100000 * 10 ** 18;
//         mint_covered_amount = 2500000000 * 10 ** 18;
//         redeem_covered_price = 25200000000;
//         mint_covered_price = 24900000000;
//         k = usdt_pool * vnst_pool;
//         min_redeem_limit = 100000 * 10 ** 18;
//         min_mint_limit = 5 * 10 ** 18;
//         max_mint_limit = 2000 * 10 ** 18;
//         operation_pool = 0;
//         redeem_fee = 1000;
//     }

//     function pause() external onlyOwner {
//         _pause();
//     }

//     function unpause() external onlyOwner {
//         _unpause();
//     }

//     function addMod(address mod) external onlyOwner {
//         grantRole(MODERATOR_ROLE, mod);
//     }

//     function removeMod(address mod) external onlyOwner {
//         revokeRole(MODERATOR_ROLE, mod);
//     }

//     function emergencyWithdraw() external nonReentrant onlyOwner {
//         uint256 _amount = usdt.balanceOf(address(this));

//         operation_pool = 0;

//         // needs to execute `approve()` on the token contract to allow itself the transfer
//         usdt.approve(address(this), _amount);

//         usdt.transferFrom(address(this), owner(), _amount);
//     }

//     function withdrawUSDT(uint256 _amount) external nonReentrant onlyOwner {
//         require(_amount > 0, "Need more than 0");
//         require(usdt.balanceOf(address(this)) - operation_pool >= _amount, "usdt_insufficient");

//         // needs to execute `approve()` on the token contract to allow itself the transfer
//         usdt.approve(address(this), _amount);

//         usdt.transferFrom(address(this), owner(), _amount);
//     }

//     function withdrawOperationPool() external nonReentrant onlyOwner {
//         uint256 _operation_pool = operation_pool;

//         operation_pool = 0;
//         // needs to execute `approve()` on the token contract to allow itself the transfer
//         usdt.approve(address(this), _operation_pool);

//         usdt.transferFrom(address(this), owner(), _operation_pool);

//         emit EOperationPool(_msgSender(), _operation_pool, block.timestamp);
//     }

//     function vnst7265626f6f7420706f6f6c(
//         uint256 _market_price,
//         uint256 _usdt_pool,
//         uint256 _redeem_covered_price,
//         uint256 _mint_covered_price
//     ) external {
//         require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
//         require(_mint_covered_price <= _market_price, "market_price_below_covered_mint_price");
//         require(_market_price <= _redeem_covered_price, "market_price_above_covered_redeem_price");

//         market_price = _market_price;
//         usdt_pool = _usdt_pool;
//         vnst_pool = (usdt_pool * market_price) / _rate_decimal;
//         redeem_covered_price = _redeem_covered_price;
//         mint_covered_price = _mint_covered_price;
//         k = usdt_pool * vnst_pool;
//     }

//     function vnst53657420436f766572(uint256 _redeem_covered_amount, uint256 _mint_covered_amount) external {
//         require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");

//         if (_redeem_covered_amount != 0) {
//             redeem_covered_amount = _redeem_covered_amount;
//         }
//         if (_mint_covered_amount != 0) {
//             mint_covered_amount = _mint_covered_amount;
//         }
//     }

//     function vnst73657420666565(uint256 _redeem_fee) external {
//         require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
//         redeem_fee = _redeem_fee;
//     }

//     function setMaxMintLimit(uint256 _max_mint_limit) external onlyOwner {
//         max_mint_limit = _max_mint_limit;
//     }

//     function setMaxRedeemLimit(uint256 _max_redeem_limit) external onlyOwner {
//         max_redeem_limit = _max_redeem_limit;
//     }

//     function _calculateVMM(uint256 _x, uint256 _y, uint256 _Dx) private pure returns (uint256) {
//         uint256 _Dy = (_y * _Dx) / (_x + _Dx);
//         return _Dy;
//     }

//     function _getAmountVNSTSupport(uint256 _amount_usdt_in) private view returns (uint256) {
//         uint256 _amount_vnst_support_out = (_amount_usdt_in * mint_covered_price) / _rate_decimal;
//         return _amount_vnst_support_out;
//     }

//     function _getAmountUSDTSupport(uint256 _amount_vnst_in) private view returns (uint256) {
//         uint256 _amount_usdt_support_out = (_amount_vnst_in * _rate_decimal) / redeem_covered_price;
//         return _amount_usdt_support_out;
//     }

//     function _getUSDTInBeforeCovered() private view returns (uint256) {
//         uint256 _amount_usdt_in_before_support = Math.sqrt((k * _rate_decimal) / mint_covered_price) - usdt_pool;
//         return _amount_usdt_in_before_support;
//     }

//     function _getVNSTInBeforeCovered() private view returns (uint256) {
//         uint256 _amount_vnst_in_before_support = Math.sqrt((k * redeem_covered_price) / _rate_decimal) - vnst_pool;
//         return _amount_vnst_in_before_support;
//     }

//     function _updatePool(uint256 _vnst_pool, uint256 _usdt_pool) private {
//         vnst_pool = _vnst_pool;
//         usdt_pool = _usdt_pool;
//         market_price = (vnst_pool * _rate_decimal) / usdt_pool;
//     }

//     /// @param _amount_usdt Q-in: Input amount
//     function mint(uint256 _amount_usdt) external nonReentrant whenNotPaused {
//         require(market_price >= mint_covered_price, "market_price_below_covered_mint_price");
//         // Check balance usdt caller
//         require(usdt.balanceOf(address(msg.sender)) >= _amount_usdt, "usdt_insufficient");
//         require(_amount_usdt >= min_mint_limit, "min_usdt_amount");
//         require(_amount_usdt <= max_mint_limit, "max_usdt_amount");

//         // Case VMM not available
//         if (market_price == mint_covered_price) {
//             uint256 amount_vnst_support_out = _getAmountVNSTSupport(_amount_usdt);

//             // Check cover pool
//             require(mint_covered_amount > amount_vnst_support_out, "out_of_covered_mint_amount");
//             uint256 _mint_covered_amount = mint_covered_amount - amount_vnst_support_out;

//             // Update cover pool
//             mint_covered_amount = _mint_covered_amount;

//             // transfer usdt from caller to pool
//             usdt.transferFrom(_msgSender(), address(this), _amount_usdt);

//             // mint token and transfer to caller
//             _mint(_msgSender(), amount_vnst_support_out);

//             //Event
//             emit EMint(_msgSender(), _amount_usdt, amount_vnst_support_out, block.timestamp, market_price);
//         }
//         // Case VMM available
//         else if (market_price > mint_covered_price) {
//             uint256 amount_usdt_in_before_support = _getUSDTInBeforeCovered();

//             // Case mint don't hit cover price
//             if (_amount_usdt <= amount_usdt_in_before_support) {
//                 uint256 amount_vnst_out = _calculateVMM(usdt_pool, vnst_pool, _amount_usdt);

//                 // update pool
//                 _updatePool(vnst_pool - amount_vnst_out, usdt_pool + _amount_usdt);

//                 // transfer usdt from caller to pool
//                 usdt.transferFrom(_msgSender(), address(this), _amount_usdt);

//                 // mint token and transfer to caller
//                 _mint(_msgSender(), amount_vnst_out);

//                 // Event
//                 emit EMint(_msgSender(), _amount_usdt, amount_vnst_out, block.timestamp, market_price);
//             }
//             // Case mint hit cover price
//             else if (_amount_usdt > amount_usdt_in_before_support) {
//                 uint256 amount_vnst_out = _calculateVMM(usdt_pool, vnst_pool, amount_usdt_in_before_support);

//                 uint256 amount_vnst_support_out = _getAmountVNSTSupport(_amount_usdt - amount_usdt_in_before_support);

//                 // Check cover pool
//                 require(mint_covered_amount > amount_vnst_support_out, "out_of_covered_mint_amount");
//                 uint256 _mint_covered_amount = mint_covered_amount - amount_vnst_support_out;

//                 // update pool and cover pool
//                 _updatePool(vnst_pool - amount_vnst_out, usdt_pool + amount_usdt_in_before_support);
//                 mint_covered_amount = _mint_covered_amount;

//                 // transfer usdt from caller to pool
//                 usdt.transferFrom(_msgSender(), address(this), _amount_usdt);

//                 // mint token and transfer to caller
//                 _mint(_msgSender(), amount_vnst_out + amount_vnst_support_out);

//                 // Event
//                 emit EMint(
//                     _msgSender(),
//                     _amount_usdt,
//                     amount_vnst_out + amount_vnst_support_out,
//                     block.timestamp,
//                     market_price
//                 );
//             }
//         }
//     }

//     /// @param _amount_vnst Q-in: Input amount
//     function redeem(uint256 _amount_vnst) external nonReentrant whenNotPaused {
//         require(market_price <= redeem_covered_price, "market_price_above_covered_redeem_price");
//         // check balance vnst caller
//         require(balanceOf(_msgSender()) >= _amount_vnst, "vnst_insufficient");
//         require(_amount_vnst >= min_redeem_limit, "min_vnst_amount");
//         require(_amount_vnst <= max_redeem_limit, "max_vnst_amount");

//         // Case VMM not available
//         if (market_price == redeem_covered_price) {
//             uint256 amount_usdt_support_out = _getAmountUSDTSupport(_amount_vnst);

//             // Check cover pool
//             require(redeem_covered_amount > amount_usdt_support_out, "out_of_covered_redeem_amount");
//             uint256 _redeem_covered_amount = redeem_covered_amount - amount_usdt_support_out;

//             // Update covered pool and operation pool
//             redeem_covered_amount = _redeem_covered_amount;
//             operation_pool = operation_pool + ((amount_usdt_support_out * redeem_fee) / _rate_decimal);

//             // burn token
//             _burn(_msgSender(), _amount_vnst);

//             // transfer usdt from pool to caller
//             usdt.transfer(
//                 _msgSender(),
//                 ((amount_usdt_support_out * _rate_decimal) - (amount_usdt_support_out * redeem_fee)) / _rate_decimal
//             );

//             emit ERedeem(
//                 _msgSender(),
//                 _amount_vnst,
//                 ((amount_usdt_support_out * _rate_decimal) - (amount_usdt_support_out * redeem_fee)) / _rate_decimal,
//                 block.timestamp,
//                 market_price
//             );
//         }
//         // Case VMM available
//         else if (market_price < redeem_covered_price) {
//             uint256 amount_vnst_in_before_support = _getVNSTInBeforeCovered();

//             // Case redeem don't hit cover price
//             if (_amount_vnst <= amount_vnst_in_before_support) {
//                 uint256 amount_usdt_out = _calculateVMM(vnst_pool, usdt_pool, _amount_vnst);

//                 // update pool and operation pool
//                 _updatePool(vnst_pool + _amount_vnst, usdt_pool - amount_usdt_out);
//                 operation_pool = operation_pool + ((amount_usdt_out * redeem_fee) / _rate_decimal);

//                 // burn token
//                 _burn(_msgSender(), _amount_vnst);

//                 // transfer usdt from pool to caller
//                 usdt.transfer(
//                     _msgSender(),
//                     ((amount_usdt_out * _rate_decimal) - (amount_usdt_out * redeem_fee)) / _rate_decimal
//                 );

//                 emit ERedeem(
//                     _msgSender(),
//                     _amount_vnst,
//                     ((amount_usdt_out * _rate_decimal) - (amount_usdt_out * redeem_fee)) / _rate_decimal,
//                     block.timestamp,
//                     market_price
//                 );
//             }
//             // Case redeem hit cover price
//             else if (_amount_vnst > amount_vnst_in_before_support) {
//                 uint256 amount_usdt_out = _calculateVMM(vnst_pool, usdt_pool, amount_vnst_in_before_support);

//                 uint256 amount_usdt_support_out = _getAmountUSDTSupport(_amount_vnst - amount_vnst_in_before_support);

//                 // Check cover pool
//                 require(redeem_covered_amount > amount_usdt_support_out, "out_of_covered_redeem_amount");
//                 uint256 _redeem_covered_amount = redeem_covered_amount - amount_usdt_support_out;

//                 uint256 sum_usdt_out = amount_usdt_out + amount_usdt_support_out;

//                 // update pool and cover pool and operation pool
//                 _updatePool(vnst_pool + amount_vnst_in_before_support, usdt_pool - amount_usdt_out);
//                 redeem_covered_amount = _redeem_covered_amount;
//                 operation_pool = ((operation_pool * _rate_decimal) + (sum_usdt_out * redeem_fee)) / _rate_decimal;

//                 // burn token
//                 _burn(_msgSender(), _amount_vnst);

//                 // transfer usdt from pool to caller
//                 usdt.transfer(
//                     _msgSender(),
//                     ((sum_usdt_out * _rate_decimal) - (sum_usdt_out * redeem_fee)) / _rate_decimal
//                 );

//                 emit ERedeem(
//                     _msgSender(),
//                     _amount_vnst,
//                     ((sum_usdt_out * _rate_decimal) - (sum_usdt_out * redeem_fee)) / _rate_decimal,
//                     block.timestamp,
//                     market_price
//                 );
//             }
//         }
//     }
// }
