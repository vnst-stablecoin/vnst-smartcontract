# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```bash
yarn install
```

Run tests and coverage

```bash
yarn test
yarn coverage
```

Create doc

```bash
hardhat docgen
```

Linting

```bash
yarn lint
yarn lint:fix
```

Formatting

```bash
yarn format
```

Hardhat

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

Proxy verify

```bash
npx hardhat verify --network bscTestnet 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c
Verifying implementation: 0x24102fa5a32e09b75A89f50A0358dE6e6128039E
The contract 0x24102fa5a32e09b75A89f50A0358dE6e6128039E has already been verified.
https://testnet.bscscan.com/address/0x24102fa5a32e09b75A89f50A0358dE6e6128039E#code
Verifying proxy: 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c
Contract at 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c already verified.
Linking proxy 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c with implementation
Successfully linked proxy to implementation.

Proxy fully verified.
```

Proxy verify after upgrade

```bash
npx hardhat verify --network bscTestnet 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c
Verifying implementation: 0x12F2E63494Cd6ea788192E195A1F3181140EcCD9
The contract 0x12F2E63494Cd6ea788192E195A1F3181140EcCD9 has already been verified.
https://testnet.bscscan.com/address/0x12F2E63494Cd6ea788192E195A1F3181140EcCD9#code
Verifying proxy: 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c
Contract at 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c already verified.
Linking proxy 0xcAE5504Da258a6752eED3fdc5C9477B3B27e5C7c with implementation
Successfully linked proxy to implementation.

Proxy fully verified.
```
