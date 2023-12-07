// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.1;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

// contract VNSC is ERC20, ERC20Pausable, AccessControlEnumerable, Ownable {
//     using SafeMath for uint256;
//     using SafeERC20Upgradeable for IERC20Upgradeable;

//     /**
//       variable
//      */
//     IERC20 public usdt;
//     bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
//     uint256 public burn_fee = 20; // fee per 10000
//     uint256 private standard_percent = 10000;
//     uint256 public rate_otc_usdt = 20000 * 10 ** 18;
//     uint256 public usdt_pool = 1000 * 10 ** 18;
//     uint256 public vnsc_pool = 20000000 * 10 ** 18;
//     uint256 public rate_spot = (vnsc_pool / usdt_pool) * 10 ** 18;
//     uint256 public total_burn_fee = 0;
//     uint256 public total_burn_fee_available = 0;
//     uint256 public min_rate_pool = 2000; // fee per 10000

//     /**
//      * @notice
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
//     event ESetBurnFee(uint256 fee, uint256 created_at);
//     event ETransferPoolFail(uint256 amount, uint256 created_at);
//     event ESetOTCRateFee(uint256 fee);
//     event ESetUSDTPool(uint256 amount);
//     event ESetVNSCPool(uint256 amount);
//     event ESetMinRateUsdt(uint256 mint_rate);

//     constructor(address address_usdt) ERC20("VNSC Token", "VNSC") {
//         usdt = IERC20(address_usdt);
//         _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
//         _setupRole(PAUSER_ROLE, _msgSender());
//     }

//     function _beforeTokenTransfer(
//         address from,
//         address to,
//         uint256 amount
//     ) internal virtual override(ERC20, ERC20Pausable) {
//         super._beforeTokenTransfer(from, to, amount);
//     }

//     function pause() public virtual {
//         require(hasRole(PAUSER_ROLE, _msgSender()), "VNSC: must have pauser role to pause");
//         _pause();
//     }

//     function unpause() public virtual {
//         require(hasRole(PAUSER_ROLE, _msgSender()), "VNSC: must have pauser role to unpause");
//         _unpause();
//     }

//     function setUsdtAddress(address _usdt) external onlyOwner {
//         usdt = IERC20(_usdt);
//     }

//     function setBurnFee(uint256 fee) public onlyOwner {
//         burn_fee = fee;

//         emit ESetBurnFee(fee, block.timestamp);
//     }

//     function setOTCRateUsdt(uint256 fee) public onlyOwner {
//         rate_otc_usdt = fee;

//         emit ESetOTCRateFee(fee);
//     }

//     function setUSDTPool(uint256 amount) public onlyOwner {
//         usdt_pool = amount;
//         reSetRateSpot(vnsc_pool, amount);

//         emit ESetUSDTPool(amount);
//     }

//     function setVNSCPool(uint256 amount) public onlyOwner {
//         vnsc_pool = amount;
//         reSetRateSpot(amount, usdt_pool);

//         emit ESetVNSCPool(amount);
//     }

//     function reSetRateSpot(uint256 new_vnsc_pool, uint256 new_usdt_pool) private onlyOwner {
//         rate_spot = (new_vnsc_pool / new_usdt_pool) * 10 ** 18;
//     }

//     function getAmoutOut(uint256 amount, string memory type_out) public view returns (uint256) {
//         // type USDT => convert usdt to vnsc and reverse
//         if (compareString(type_out, "USDT")) {
//             return amount.mul(rate_spot / 10 ** 18);
//         } else {
//             // convert vnsc to usdt
//             return ((amount * 10 ** 18) / rate_spot);
//         }
//     }

//     function mint(uint256 amount_usdt) public {
//         require(usdt.balanceOf(address(msg.sender)) >= amount_usdt, "USDT does't enough");
//         require(amount_usdt >= 5 * 10 ** 18, "Min amount usdt is 5");
//         require(rate_spot >= rate_otc_usdt - ((rate_otc_usdt * 5) / 100));

//         uint256 amout_out_vnsc = getAmoutOut(amount_usdt, "USDT");

//         // transfer usdt from caller to pool
//         usdt.transferFrom(_msgSender(), address(this), amount_usdt);

//         // mint token and transfer to caller
//         _mint(_msgSender(), amout_out_vnsc);

//         // Get VNSC out of pool
//         vnsc_pool = vnsc_pool - amout_out_vnsc;

//         // Get USDT in pool
//         usdt_pool = usdt_pool + amount_usdt;

//         // Update rate spot
//         rate_spot = (vnsc_pool / usdt_pool) * 10 ** 18;

//         emit EMint(_msgSender(), amount_usdt, amout_out_vnsc, block.timestamp);
//     }

//     function burn(uint256 amount_vnsc) public returns (string memory) {
//         // check balance vnsc caller
//         require(balanceOf(_msgSender()) >= amount_vnsc, "VNSC does't enough");
//         require(amount_vnsc >= 100_000 * 10 ** 18, "Min amount vnsc is 100");
//         require(rate_spot <= rate_otc_usdt + ((rate_otc_usdt * 5) / 100));

//         uint256 amount_usdt_out = getAmoutOut(amount_vnsc, "VNSC");

//         // check balance usdt pool
//         if (usdt.balanceOf(address(this)) < amount_usdt_out) {
//             emit ETransferPoolFail(amount_vnsc, block.timestamp);

//             revert("USDT Pool does't enough");
//         }

//         uint256 fee = (amount_usdt_out * burn_fee) / standard_percent;

//         // burn token
//         _burn(_msgSender(), amount_vnsc);

//         // Get VNSC in pool
//         vnsc_pool = vnsc_pool + amount_vnsc;

//         // Get USDT out of pool
//         usdt_pool = usdt_pool - amount_usdt_out;

//         // Update rate spot
//         rate_spot = (vnsc_pool / usdt_pool) * 10 ** 18;

//         // transfer usdt from pool to caller
//         usdt.transfer(_msgSender(), amount_usdt_out - fee);

//         total_burn_fee = total_burn_fee + fee;
//         total_burn_fee_available = total_burn_fee_available + fee;

//         emit EBurn(_msgSender(), amount_vnsc, amount_usdt_out, block.timestamp);

//         return "success";
//     }

//     function withDrawBurnFee(address receiver) public onlyOwner {
//         usdt.transfer(receiver, total_burn_fee_available);
//         total_burn_fee_available = 0;
//     }

//     function withDrawUSDT(address receiver, uint256 amount) public onlyOwner {
//         uint256 min_amount = usdt.balanceOf(address(this)) -
//             ((usdt.balanceOf(address(this)) * min_rate_pool) / standard_percent);
//         require(min_amount > amount, "Exceed the allowed amount");

//         usdt.transfer(receiver, amount);
//     }

//     function getMaxAmountWithdraw() public view returns (uint256) {
//         uint min = usdt.balanceOf(address(this)) -
//             ((usdt.balanceOf(address(this)) * min_rate_pool) / standard_percent);

//         return min;
//     }

//     function setMinRate(uint256 rate) public onlyOwner {
//         min_rate_pool = rate;

//         emit ESetMinRateUsdt(rate);
//     }

//     function balanceOfUSDT() public view returns (uint256) {
//         uint256 balance_usdt = usdt.balanceOf(address(this));

//         return balance_usdt;
//     }

//     /*
//      @helper
//     **/
//     function compareString(string memory a, string memory b) private pure returns (bool) {
//         return keccak256(bytes(a)) == keccak256(bytes(b));
//     }
// }
