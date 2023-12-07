# vnst deployment instruction

1. Create .env from .env.example
2. Fill in the main net information:

    ```bash
    MAINNETKEY=
    MAINNETAPI=
    USDTMAINNETADDRESS=
    ```

3. Run

    ```bash
        npx hardhat run --network bscMainnet scripts/prod/deploy_vnst_proxy.ts
    ```

    Should look like this:

    ```bash
    npx hh run --network bscTestnet scripts/staging/deploy_vnst_proxy.ts
    Deploying VNST Proxy ...
    VNST Proxy deployed to: 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    ```

4. Copy the proxy deployed address, put it in the .env

    ```bash
    PROXYMAINNETADDRESS=
    ```

5. Verify the proxy address

    ```bash
        npx hardhat verify --network bscMainnet PROXYMAINNETADDRESS
    ```

    Should look like this

    ```bash
    npx hardhat verify --network bscTestnet 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    Verifying implementation: 0xdb4f71E75d87236e5111f7c3f4D9E2f160291d82
    Successfully submitted source code for contract
    contracts/vnst.proxy.sol:VNSTProxy at 0xdb4f71E75d87236e5111f7c3f4D9E2f160291d82
    for verification on the block explorer. Waiting for verification result...

    Successfully verified contract VNSTProxy on the block explorer.
    https://testnet.bscscan.com/address/0xdb4f71E75d87236e5111f7c3f4D9E2f160291d82#code
    Verifying proxy: 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    Contract at 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F already verified.
    Linking proxy 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F with implementation
    Successfully linked proxy to implementation.

    Proxy fully verified.
    ```

6. Upgrade smart contract

    ```bash
    npx hardhat run --network bscMainnet scripts/prod/upgrade_vnst_bnbMainnet.ts
    ```

    Should look like this

    ```bash
    npx hh run --network bscTestnet scripts/staging/upgrade_vnst_bnbTestnet.ts
    Upgrading VNST ...
    VNST deployed to: 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    ```

7. Verify

    ```bash
            npx hardhat verify --network bscMainnet PROXYMAINNETADDRESS
    ```

    Should look like this

    ```bash
    npx hh verify --network bscTestnet 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    Verifying implementation: 0xE90C926Ca837E23D9CCD82EF88bc3EB4EB429397
    Successfully submitted source code for contract
    contracts/vnst.upgrade.sol:VNST at 0xE90C926Ca837E23D9CCD82EF88bc3EB4EB429397
    for verification on the block explorer. Waiting for verification result...

    Successfully verified contract VNST on the block explorer.
    https://testnet.bscscan.com/address/0xE90C926Ca837E23D9CCD82EF88bc3EB4EB429397#code
    Verifying proxy: 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F
    Contract at 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F already verified.
    Linking proxy 0xcD3d63EaE54efe4607C56c8Af9Ca3F76a84aA30F with implementation
    Successfully linked proxy to implementation.

    Proxy fully verified.
    ```
