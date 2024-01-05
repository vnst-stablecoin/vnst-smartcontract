# AUTO mint and redeem VNST guideline

```bash
mkdir auto
cd auto
yarn init -y
touch index.js
yarn add ethers
```

Inside `index.js`

```js
const { ethers, JsonRpcProvider } = require("ethers");

const abi = ABI;

// Testnet Provider
const provider = new JsonRpcProvider(
  "https://bsc-testnet.nodereal.io/v1/df4db9085ad0438799353c3ea5104420",
  97
);

// Mainnet Provider
// const provider = new JsonRpcProvider(
//   "https://bsc-mainnet.nodereal.io/v1/df4db9085ad0438799353c3ea5104420",
//   56
// );

const signer = new ethers.Wallet("WALLET_PRIVATE_KEY", provider);

// Testnet
const vnst = new ethers.Contract(
  "0xFBF7B3Cf3938A29099F76e511dE96a7e316Fdf33",
  abi,
  signer
);

// Mainnet
// const vnst = new ethers.Contract(
//     "0x3B26Fb89Eab263cC6CB1E91F611BAe8793F927Ef",
//     abi,
//     signer
//   );

const main = async () => {
  await vnst.mint(ethers.parseEther("2000"));
  await vnst.redeem(ethers.parseEther("100000"));
};

main();

```

Replace `ABI` with `abi.json`

Replace `WALLET_PRIVATE_KEY` with your private key

And then run

```bash
node index.js
```
