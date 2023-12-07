# Solidity API

## MockVNST

### setMarketPrice

```solidity
function setMarketPrice(uint256 _market_price) external
```

### hackMint

```solidity
function hackMint() external
```

## VNSTProxy

VNST Stable Coin and VMM

### MODERATOR_ROLE

```solidity
bytes32 MODERATOR_ROLE
```

### usdt

```solidity
contract IERC20 usdt
```

USDT (u)
VNST (v)
R-center = v / u
Q-Support above
Q-Support bellow
R-Support above
R-Support bellow
k constant = u * v
operation_pool

### usdt_pool

```solidity
uint256 usdt_pool
```

### vnst_pool

```solidity
uint256 vnst_pool
```

### market_price

```solidity
uint256 market_price
```

### redeem_covered_amount

```solidity
uint256 redeem_covered_amount
```

### mint_covered_amount

```solidity
uint256 mint_covered_amount
```

### redeem_covered_price

```solidity
uint256 redeem_covered_price
```

### mint_covered_price

```solidity
uint256 mint_covered_price
```

### k

```solidity
uint256 k
```

### min_redeem_limit

```solidity
uint256 min_redeem_limit
```

### min_mint_limit

```solidity
uint256 min_mint_limit
```

### max_mint_limit

```solidity
uint256 max_mint_limit
```

### operation_pool

```solidity
uint256 operation_pool
```

### redeem_fee

```solidity
uint256 redeem_fee
```

### _rate_decimal

```solidity
uint256 _rate_decimal
```

### initialize

```solidity
function initialize(address address_usdt) public
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| address_usdt | address | address of usdt stable coin |

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address newImplementation) internal
```

_Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
{upgradeTo} and {upgradeToAndCall}.

Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.

```solidity
function _authorizeUpgrade(address) internal override onlyOwner {}
```_

### pause

```solidity
function pause() external
```

### unpause

```solidity
function unpause() external
```

### addMod

```solidity
function addMod(address mod) external
```

### removeMod

```solidity
function removeMod(address mod) external
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual
```

## VNSTProtocol

### version

```solidity
function version() external pure returns (string)
```

### EMint

```solidity
event EMint(address address_mint, uint256 amount_in, uint256 amount_out, uint256 created_at, uint256 market_price)
```

Event

### ERedeem

```solidity
event ERedeem(address address_withdraw, uint256 amount_in, uint256 amount_out, uint256 created_at, uint256 market_price)
```

### EOperationPool

```solidity
event EOperationPool(address address_withdraw, uint256 amount, uint256 created_at)
```

### emergencyWithdraw

```solidity
function emergencyWithdraw() external
```

### withdrawUSDT

```solidity
function withdrawUSDT(uint256 amount) external
```

### withdrawOperationPool

```solidity
function withdrawOperationPool() external
```

### vnst7265626f6f7420706f6f6c

```solidity
function vnst7265626f6f7420706f6f6c(uint256 _market_price, uint256 _usdt_pool, uint256 _redeem_covered_price, uint256 _mint_covered_price) external
```

### vnst53657420436f766572

```solidity
function vnst53657420436f766572(uint256 _redeem_covered_amount, uint256 _mint_covered_amount) external
```

### vnst73657420666565

```solidity
function vnst73657420666565(uint256 _redeem_fee) external
```

### setMaxMintLimit

```solidity
function setMaxMintLimit(uint256 _max_mint_limit) external
```

### mint

```solidity
function mint(uint256 amount_usdt) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_usdt | uint256 | Q-in: Input amount |

### redeem

```solidity
function redeem(uint256 amount_vnst) external
```

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount_vnst | uint256 | Q-in: Input amount |

## USDT

### constructor

```solidity
constructor() public
```

