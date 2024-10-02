// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import "./vnst.proxy.sol";

contract VNSTProtocol is VNSTProxy {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public max_redeem_limit;
    EnumerableSet.AddressSet private verifiedUsers;
    uint256 public max_mint_limit_verified_user;
    uint256 public max_redeem_limit_verified_user;
    uint256 public mint_fee;
    bool public mint_status;
    bool public redeem_status;
    uint256 max_fee_by_percent;
    uint256 max_uint;

    function version() external pure returns (string memory) {
        return "v1!";
    }

    /**
     * @notice Event
     */
    event EMint(
        address indexed address_mint,
        uint256 amount_in,
        uint256 amount_out,
        uint256 created_at,
        uint256 market_price
    );
    event ERedeem(
        address indexed address_withdraw,
        uint256 amount_in,
        uint256 amount_out,
        uint256 created_at,
        uint256 market_price
    );

    event EOperationPool(address indexed address_withdraw, uint256 amount, uint256 created_at);

    function initializeData() public onlyOwner {
        max_fee_by_percent = 100000;
        max_uint = type(uint256).max;
    }

    function emergencyWithdraw() external nonReentrant onlyOwner {
        uint256 _amount = usdt.balanceOf(address(this));

        operation_pool = 0;

        usdt.transfer(owner(), _amount);
    }

    function withdrawUSDT(uint256 _amount) external nonReentrant onlyOwner {
        require(_amount > 0, "Need more than 0");
        require(usdt.balanceOf(address(this)) - operation_pool >= _amount, "usdt_insufficient");

        usdt.transfer(owner(), _amount);
    }

    function withdrawOperationPool() external nonReentrant onlyOwner {
        uint256 _operation_pool = operation_pool;

        operation_pool = 0;

        usdt.transfer(owner(), _operation_pool);

        emit EOperationPool(_msgSender(), _operation_pool, block.timestamp);
    }

    function vnst7265626f6f7420706f6f6c(
        uint256 _market_price,
        uint256 _usdt_pool,
        uint256 _redeem_covered_price,
        uint256 _mint_covered_price
    ) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        require(_mint_covered_price <= _market_price, "market_price_below_covered_mint_price");
        require(_market_price <= _redeem_covered_price, "market_price_above_covered_redeem_price");

        market_price = _market_price;
        usdt_pool = _usdt_pool;
        vnst_pool = (usdt_pool * market_price) / _rate_decimal;
        redeem_covered_price = _redeem_covered_price;
        mint_covered_price = _mint_covered_price;
        k = usdt_pool * vnst_pool;
    }

    function vnst53657420436f766572(uint256 _redeem_covered_amount, uint256 _mint_covered_amount) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");

        if (_redeem_covered_amount != 0) {
            redeem_covered_amount = _redeem_covered_amount;
        }
        if (_mint_covered_amount != 0) {
            mint_covered_amount = _mint_covered_amount;
        }
    }

    function vnst73657420666565(uint256 _redeem_fee) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        require(_redeem_fee < max_fee_by_percent, "exceed_the_limit");
        redeem_fee = _redeem_fee;
    }

    function setMaxMintLimit(uint256 _max_mint_limit) external onlyOwner {
        max_mint_limit = _max_mint_limit;
    }

    function setMaxRedeemLimit(uint256 _max_redeem_limit) external onlyOwner {
        max_redeem_limit = _max_redeem_limit;
    }

    function _calculateVMM(uint256 _x, uint256 _y, uint256 _Dx) private pure returns (uint256) {
        uint256 _Dy = (_y * _Dx) / (_x + _Dx);
        return _Dy;
    }

    function _getAmountVNSTSupport(uint256 _amount_usdt_in) private view returns (uint256) {
        uint256 _amount_vnst_support_out = (_amount_usdt_in * mint_covered_price) / _rate_decimal;
        return _amount_vnst_support_out;
    }

    function _getAmountUSDTSupport(uint256 _amount_vnst_in) private view returns (uint256) {
        uint256 _amount_usdt_support_out = (_amount_vnst_in * _rate_decimal) / redeem_covered_price;
        return _amount_usdt_support_out;
    }

    function _getUSDTInBeforeCovered() private view returns (uint256) {
        uint256 _amount_usdt_in_before_support = Math.sqrt((k * _rate_decimal) / mint_covered_price) - usdt_pool;
        return _amount_usdt_in_before_support;
    }

    function _getVNSTInBeforeCovered() private view returns (uint256) {
        uint256 _amount_vnst_in_before_support = Math.sqrt((k * redeem_covered_price) / _rate_decimal) - vnst_pool;
        return _amount_vnst_in_before_support;
    }

    function _updatePool(uint256 _vnst_pool, uint256 _usdt_pool) private {
        vnst_pool = _vnst_pool;
        usdt_pool = _usdt_pool;
        market_price = (vnst_pool * _rate_decimal) / usdt_pool;
    }

    function vnst73657420666566(uint256 _mint_fee) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        require(_mint_fee < max_fee_by_percent, "exceed_the_limit");
        mint_fee = _mint_fee;
    }

    function setMaxLimitVerifiedUser(uint256 _max_mint_limit, uint256 _max_redeem_limit) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        max_mint_limit_verified_user = _max_mint_limit;
        max_redeem_limit_verified_user = _max_redeem_limit;
    }

    function isVerified(address _user) public view returns (bool) {
        return verifiedUsers.contains(_user);
    }

    function addVerifiedUsers(address[] calldata _users) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        for (uint8 i = 0; i < _users.length; i++) {
            verifiedUsers.add(_users[i]);
        }
    }

    function removeVerifiedUsers(address[] calldata _users) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        for (uint8 i = 0; i < _users.length; i++) {
            verifiedUsers.remove(_users[i]);
        }
    }

    function getAllVerifiedUsers() external view returns (address[] memory) {
        uint256 _count = verifiedUsers.length();
        address[] memory users = new address[](_count);
        for (uint256 i = 0; i < _count; i++) {
            users[i] = verifiedUsers.at(i);
        }
        return users;
    }

    function vnst191671e7f585a3817f(bool _mint_status) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        mint_status = _mint_status;
    }

    function vnst5630dd9d602fe45ab7(bool _redeem_status) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "caller_lacks_necessary_permission");
        redeem_status = _redeem_status;
    }

    /// @param _amount_usdt Q-in: Input amount
    function mint(uint256 _amount_usdt) external nonReentrant whenNotPaused {
        require(mint_status, "caller_lacks_necessary_permission");
        uint256 _max_limit;

        if (isVerified(msg.sender)) {
            _max_limit = max_mint_limit_verified_user;
        } else {
            _max_limit = max_mint_limit;
        }
        require(market_price >= mint_covered_price, "market_price_below_covered_mint_price");
        // Check balance usdt caller
        require(usdt.balanceOf(address(msg.sender)) >= _amount_usdt, "usdt_insufficient");
        require(_amount_usdt >= min_mint_limit, "min_usdt_amount");
        require(_amount_usdt <= _max_limit, "max_usdt_amount");

        uint256 _amount_usdt_mint = _amount_usdt - _amount_usdt * mint_fee / _rate_decimal;
        operation_pool = operation_pool + (_amount_usdt - _amount_usdt_mint);
        // Case VMM not available
        if (market_price == mint_covered_price) {
            uint256 amount_vnst_support_out = _getAmountVNSTSupport(_amount_usdt_mint);

            // Check cover pool
            require(mint_covered_amount > amount_vnst_support_out, "out_of_covered_mint_amount");
            uint256 _mint_covered_amount = mint_covered_amount - amount_vnst_support_out;

            // Update cover pool
            mint_covered_amount = _mint_covered_amount;

            // transfer usdt from caller to pool
            usdt.transferFrom(_msgSender(), address(this), _amount_usdt);


            // mint token and transfer to caller
            require(totalSupply() + amount_vnst_support_out <= max_uint, "storage_limit_exceeded");
            _mint(_msgSender(), amount_vnst_support_out);

            //Event
            emit EMint(_msgSender(), _amount_usdt, amount_vnst_support_out, block.timestamp, market_price);
        }
            // Case VMM available
        else if (market_price > mint_covered_price) {
            uint256 amount_usdt_in_before_support = _getUSDTInBeforeCovered();

            // Case mint don't hit cover price
            if (_amount_usdt_mint <= amount_usdt_in_before_support) {
                uint256 amount_vnst_out = _calculateVMM(usdt_pool, vnst_pool, _amount_usdt_mint);

                // update pool
                _updatePool(vnst_pool - amount_vnst_out, usdt_pool + _amount_usdt_mint);

                // transfer usdt from caller to pool
                usdt.transferFrom(_msgSender(), address(this), _amount_usdt);

                // mint token and transfer to caller
                require(totalSupply() + amount_vnst_out <= max_uint, "storage_limit_exceeded");
                _mint(_msgSender(), amount_vnst_out);

                // Event
                emit EMint(_msgSender(), _amount_usdt, amount_vnst_out, block.timestamp, market_price);
            }
                // Case mint hit cover price
            else if (_amount_usdt_mint > amount_usdt_in_before_support) {
                uint256 amount_vnst_out = _calculateVMM(usdt_pool, vnst_pool, amount_usdt_in_before_support);

                uint256 amount_vnst_support_out = _getAmountVNSTSupport(_amount_usdt_mint - amount_usdt_in_before_support);

                // Check cover pool
                require(mint_covered_amount > amount_vnst_support_out, "out_of_covered_mint_amount");
                uint256 _mint_covered_amount = mint_covered_amount - amount_vnst_support_out;

                // update pool and cover pool
                _updatePool(vnst_pool - amount_vnst_out, usdt_pool + amount_usdt_in_before_support);
                mint_covered_amount = _mint_covered_amount;

                // transfer usdt from caller to pool
                usdt.transferFrom(_msgSender(), address(this), _amount_usdt);
                // mint token and transfer to caller
                uint256 total_vnst_out = amount_vnst_out + amount_vnst_support_out;
                require(totalSupply() + total_vnst_out <= max_uint, "storage_limit_exceeded");
                _mint(_msgSender(), total_vnst_out);

                // Event
                emit EMint(
                    _msgSender(),
                    _amount_usdt,
                    amount_vnst_out + amount_vnst_support_out,
                    block.timestamp,
                    market_price
                );
            }
        }
    }

    /// @param _amount_vnst Q-in: Input amount
    function redeem(uint256 _amount_vnst) external nonReentrant whenNotPaused {
        require(redeem_status, "caller_lacks_necessary_permission");
        uint256 _max_limit;

        if (isVerified(msg.sender)) {
            _max_limit = max_redeem_limit_verified_user;
        } else {
            _max_limit = max_redeem_limit;
        }
        require(market_price <= redeem_covered_price, "market_price_above_covered_redeem_price");
        // check balance vnst caller
        require(balanceOf(_msgSender()) >= _amount_vnst, "vnst_insufficient");
        require(_amount_vnst >= min_redeem_limit, "min_vnst_amount");
        require(_amount_vnst <= _max_limit, "max_vnst_amount");

        // Case VMM not available
        if (market_price == redeem_covered_price) {
            uint256 amount_usdt_support_out = _getAmountUSDTSupport(_amount_vnst);

            // Check cover pool
            require(redeem_covered_amount > amount_usdt_support_out, "out_of_covered_redeem_amount");
            uint256 _redeem_covered_amount = redeem_covered_amount - amount_usdt_support_out;

            // Update covered pool and operation pool
            redeem_covered_amount = _redeem_covered_amount;
            operation_pool = operation_pool + ((amount_usdt_support_out * redeem_fee) / _rate_decimal);

            // burn token
            _burn(_msgSender(), _amount_vnst);

            // transfer usdt from pool to caller
            usdt.transfer(
                _msgSender(),
                ((amount_usdt_support_out * _rate_decimal) - (amount_usdt_support_out * redeem_fee)) / _rate_decimal
            );

            emit ERedeem(
                _msgSender(),
                _amount_vnst,
                ((amount_usdt_support_out * _rate_decimal) - (amount_usdt_support_out * redeem_fee)) / _rate_decimal,
                block.timestamp,
                market_price
            );
        }
            // Case VMM available
        else if (market_price < redeem_covered_price) {
            uint256 amount_vnst_in_before_support = _getVNSTInBeforeCovered();

            // Case redeem don't hit cover price
            if (_amount_vnst <= amount_vnst_in_before_support) {
                uint256 amount_usdt_out = _calculateVMM(vnst_pool, usdt_pool, _amount_vnst);

                // update pool and operation pool
                _updatePool(vnst_pool + _amount_vnst, usdt_pool - amount_usdt_out);
                operation_pool = operation_pool + ((amount_usdt_out * redeem_fee) / _rate_decimal);

                // burn token
                _burn(_msgSender(), _amount_vnst);

                // transfer usdt from pool to caller
                usdt.transfer(
                    _msgSender(),
                    ((amount_usdt_out * _rate_decimal) - (amount_usdt_out * redeem_fee)) / _rate_decimal
                );

                emit ERedeem(
                    _msgSender(),
                    _amount_vnst,
                    ((amount_usdt_out * _rate_decimal) - (amount_usdt_out * redeem_fee)) / _rate_decimal,
                    block.timestamp,
                    market_price
                );
            }
                // Case redeem hit cover price
            else if (_amount_vnst > amount_vnst_in_before_support) {
                uint256 amount_usdt_out = _calculateVMM(vnst_pool, usdt_pool, amount_vnst_in_before_support);

                uint256 amount_usdt_support_out = _getAmountUSDTSupport(_amount_vnst - amount_vnst_in_before_support);

                // Check cover pool
                require(redeem_covered_amount > amount_usdt_support_out, "out_of_covered_redeem_amount");
                uint256 _redeem_covered_amount = redeem_covered_amount - amount_usdt_support_out;

                uint256 sum_usdt_out = amount_usdt_out + amount_usdt_support_out;

                // update pool and cover pool and operation pool
                _updatePool(vnst_pool + amount_vnst_in_before_support, usdt_pool - amount_usdt_out);
                redeem_covered_amount = _redeem_covered_amount;
                operation_pool = ((operation_pool * _rate_decimal) + (sum_usdt_out * redeem_fee)) / _rate_decimal;

                // burn token
                _burn(_msgSender(), _amount_vnst);

                // transfer usdt from pool to caller
                usdt.transfer(
                    _msgSender(),
                    ((sum_usdt_out * _rate_decimal) - (sum_usdt_out * redeem_fee)) / _rate_decimal
                );

                emit ERedeem(
                    _msgSender(),
                    _amount_vnst,
                    ((sum_usdt_out * _rate_decimal) - (sum_usdt_out * redeem_fee)) / _rate_decimal,
                    block.timestamp,
                    market_price
                );
            }
        }
    }
}
