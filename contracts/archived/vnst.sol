// // SPDX-License-Identifier: SEE LICENSE IN LICENSE
// pragma solidity ^0.8.1;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// import "@openzeppelin/contracts/utils/math/Math.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/security/PullPayment.sol";

// /// @title VNST Stable Coin Smart Contract
// /// @author Nami Inovation
// /// @notice VNST Stable Coin and VNST AMM
// contract VNST is ERC20, ERC20Pausable, AccessControlEnumerable, Ownable, ReentrancyGuard {
//     using SafeMath for uint256;
//     using SafeERC20Upgradeable for IERC20Upgradeable;

//     /// @notice USDT (u)
//     /// @notice VNST (v)
//     /// @notice R-center = v / u
//     /// @notice Q-Support above
//     /// @notice Q-Support bellow
//     /// @notice R-Support above
//     /// @notice R-Support bellow
//     /// @notice k constant = u * v
//     IERC20 public usdt;
//     bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
//     uint256 public usdt_pool = 10000000 * 10 ** 18;
//     uint256 public vnst_pool = 250000000000 * 10 ** 18;
//     uint256 public r_center = vnst_pool / usdt_pool;
//     uint256 public q_support_above = 500000000 * 10 ** 18;
//     uint256 public q_support_bellow = 500000000 * 10 ** 18;
//     uint256 public r_support_above = 25200;
//     uint256 public r_support_bellow = 24950;
//     uint256 public k = usdt_pool * vnst_pool;
//     uint256 public operation_pool;

//     /**
//      * @notice Event
//      */
//     event EMint(
//         address indexed address_mint,
//         uint256 amount_usdt_in,
//         uint256 amount_vnsc_out,
//         uint256 created_at
//     );
//     event EBurn(
//         address indexed address_withdrawl,
//         uint256 vnsc_in,
//         uint256 usdt_out,
//         uint256 created_at
//     );

//     constructor(address address_usdt) ERC20("VNST Token", "VNST") {
//         usdt = IERC20(address_usdt);
//         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
//         _setupRole(PAUSER_ROLE, _msgSender());
//     }

//     function pause() external onlyOwner {
//         _pause();
//     }

//     function unpause() external onlyOwner {
//         _unpause();
//     }

//     function _beforeTokenTransfer(
//         address from,
//         address to,
//         uint256 amount
//     ) internal virtual override(ERC20, ERC20Pausable) whenNotPaused {
//         super._beforeTokenTransfer(from, to, amount);
//     }

//     // @todo remove before prod
//     function reBootPool(
//         uint256 _usdt_pool,
//         uint256 _vnst_pool,
//         uint256 _q_support_above,
//         uint256 _q_support_bellow,
//         uint256 _r_support_above,
//         uint256 _r_support_bellow
//     ) external onlyOwner {
//         usdt_pool = _usdt_pool;
//         vnst_pool = _vnst_pool;
//         r_center = vnst_pool / usdt_pool;
//         q_support_above = _q_support_above;
//         q_support_bellow = _q_support_bellow;
//         r_support_above = _r_support_above;
//         r_support_bellow = _r_support_bellow;
//         k = usdt_pool * vnst_pool;
//     }

//     function _getAmountVNSTOut(uint256 amount_usdt) private view returns (uint256) {
//         uint256 amount_vnst_out = (vnst_pool * amount_usdt) / (amount_usdt + usdt_pool);
//         return amount_vnst_out;
//     }

//     function _getAmountUSDTOut(uint256 amount_vnst) private view returns (uint256) {
//         uint256 amount_usdt_out = (usdt_pool * amount_vnst) / (amount_vnst + vnst_pool);
//         return amount_usdt_out;
//     }

//     function _getAmountVNSTSupport(uint256 amount_usdt_in) private view returns (uint256) {
//         uint256 amount_vnst_support_out = amount_usdt_in * r_center;
//         return amount_vnst_support_out;
//     }

//     function _getUSDTInBeforeSupport() private view returns (uint256) {
//         uint256 amount_usdt_in_before_support = Math.sqrt(k / r_support_bellow) - usdt_pool;
//         return amount_usdt_in_before_support;
//     }

//     function _getVNSTInBeforeSupport() private view returns (uint256) {
//         uint256 amount_vnst_in_before_support = Math.sqrt(k * r_support_above) - vnst_pool;
//         return amount_vnst_in_before_support;
//     }

//     function _updatePool(uint256 _vnst_pool, uint256 _usdt_pool) private {
//         vnst_pool = _vnst_pool;
//         usdt_pool = _usdt_pool;
//         r_center = vnst_pool / usdt_pool;
//     }

//     function mint(uint256 amount_usdt) external nonReentrant whenNotPaused {
//         // Check balance usdt caller
//         require(usdt.balanceOf(address(msg.sender)) >= amount_usdt, "USDT does't enough");
//         require(amount_usdt >= 5 * 10 ** 18, "Min amount usdt is 5");
//         require(r_center >= r_support_bellow, "Please wait for more support");

//         // Case VMM not avaiable
//         if (r_center == r_support_bellow) {
//             uint256 amount_vnst_support_out = _getAmountVNSTSupport(amount_usdt);

//             // Update support pool
//             q_support_bellow = q_support_bellow - amount_vnst_support_out;
//             require(q_support_bellow > 0, "Run out of Q support bellow");

//             // transfer usdt from caller to pool
//             usdt.transferFrom(_msgSender(), address(this), amount_usdt);

//             // mint token and transfer to caller
//             _mint(_msgSender(), amount_vnst_support_out);

//             //Event
//             emit EMint(_msgSender(), amount_usdt, amount_vnst_support_out, block.timestamp);
//         }
//         // Case VMM available
//         else if (r_center > r_support_bellow) {
//             uint256 amount_usdt_in_before_support = _getUSDTInBeforeSupport();

//             // Case mint don't hit r support
//             if (amount_usdt <= amount_usdt_in_before_support) {
//                 uint256 amount_vnst_out = _getAmountVNSTOut(amount_usdt);

//                 // update pool
//                 _updatePool(vnst_pool - amount_vnst_out, usdt_pool + amount_usdt);

//                 // transfer usdt from caller to pool
//                 usdt.transferFrom(_msgSender(), address(this), amount_usdt);

//                 // mint token and transfer to caller
//                 _mint(_msgSender(), amount_vnst_out);

//                 // Event
//                 emit EMint(_msgSender(), amount_usdt, amount_vnst_out, block.timestamp);
//             }
//             // Case mint hit r support
//             else if (amount_usdt > amount_usdt_in_before_support) {
//                 uint256 amount_vnst_out = _getAmountVNSTOut(amount_usdt_in_before_support);

//                 // update pool
//                 _updatePool(vnst_pool - amount_vnst_out, usdt_pool + amount_usdt_in_before_support);

//                 uint256 amount_vnst_support_out = _getAmountVNSTSupport(
//                     amount_usdt - amount_usdt_in_before_support
//                 );

//                 // Update support pool
//                 q_support_bellow = q_support_bellow - amount_vnst_support_out;
//                 require(q_support_bellow > 0, "Run out of Q support bellow");

//                 // transfer usdt from caller to pool
//                 usdt.transferFrom(_msgSender(), address(this), amount_usdt);

//                 // mint token and transfer to caller
//                 _mint(_msgSender(), amount_vnst_out + amount_vnst_support_out);

//                 // Event
//                 emit EMint(
//                     _msgSender(),
//                     amount_usdt,
//                     amount_vnst_out + amount_vnst_support_out,
//                     block.timestamp
//                 );
//             }
//         }
//     }

//     function burn(uint256 amount_vnst) external nonReentrant whenNotPaused {
//         // check balance vnst caller
//         require(balanceOf(_msgSender()) >= amount_vnst, "VNST does't enough");
//         require(amount_vnst >= 100_000 * 10 ** 18, "Min amount vnst is 100");
//         require(r_center <= r_support_above, "Please wait for more support");

//         // Case VMM not available
//         if (r_center == r_support_above) {
//             // Update support pool
//             q_support_above = q_support_above - amount_vnst;
//             require(q_support_above > 0, "Run out of Q support above");

//             uint256 converted_usdt = amount_vnst / r_center;

//             operation_pool = operation_pool + (converted_usdt / 1000);

//             // burn token
//             _burn(_msgSender(), amount_vnst);

//             // transfer usdt from pool to caller
//             usdt.transfer(_msgSender(), converted_usdt - (converted_usdt / 1000));

//             emit EBurn(
//                 _msgSender(),
//                 amount_vnst,
//                 converted_usdt - (converted_usdt / 1000),
//                 block.timestamp
//             );
//         }
//         // Case VMM available
//         else if (r_center < r_support_above) {
//             uint256 amount_vnst_in_before_support = _getVNSTInBeforeSupport();

//             // Case burn don't hit r support
//             if (amount_vnst <= amount_vnst_in_before_support) {
//                 uint256 amount_usdt_out = _getAmountUSDTOut(amount_vnst);

//                 // update pool
//                 _updatePool(vnst_pool + amount_vnst, usdt_pool - amount_usdt_out);

//                 operation_pool = operation_pool + (amount_usdt_out / 1000);

//                 // burn token
//                 _burn(_msgSender(), amount_vnst);

//                 // transfer usdt from pool to caller
//                 usdt.transfer(_msgSender(), amount_usdt_out - (amount_usdt_out / 1000));

//                 emit EBurn(
//                     _msgSender(),
//                     amount_vnst,
//                     amount_usdt_out - (amount_usdt_out / 1000),
//                     block.timestamp
//                 );
//             }
//             // Case burn hit r support
//             else if (amount_vnst > amount_vnst_in_before_support) {
//                 uint256 amount_usdt_out = _getAmountUSDTOut(amount_vnst_in_before_support);

//                 // update pool
//                 _updatePool(vnst_pool + amount_vnst_in_before_support, usdt_pool - amount_usdt_out);

//                 uint256 amount_vnst_support_out = amount_vnst - amount_vnst_in_before_support;
//                 uint256 amount_usdt_support_out = amount_vnst_support_out / r_center;

//                 // Update support pool
//                 q_support_above = q_support_above - amount_vnst_support_out;
//                 require(q_support_above > 0, "Run out of Q support above");

//                 uint256 sum_usdt_out = amount_usdt_out + amount_usdt_support_out;

//                 operation_pool = operation_pool + (sum_usdt_out / 1000);

//                 // burn token
//                 _burn(_msgSender(), amount_vnst);

//                 // transfer usdt from pool to caller
//                 usdt.transfer(_msgSender(), sum_usdt_out - (sum_usdt_out / 1000));

//                 emit EBurn(
//                     _msgSender(),
//                     amount_vnst,
//                     sum_usdt_out - (sum_usdt_out / 1000),
//                     block.timestamp
//                 );
//             }
//         }
//     }

//     /**
//      * @dev transfer the token from the address of this contract
//      * to address of the owner
//      */
//     function withdrawToken(uint256 _amount) external nonReentrant onlyOwner {
//         // needs to execute `approve()` on the token contract to allow itself the transfer
//         usdt.approve(address(this), _amount);

//         usdt.transferFrom(address(this), owner(), _amount);
//     }
// }
