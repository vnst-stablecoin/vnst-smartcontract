import "solidity-docgen"
import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "@openzeppelin/hardhat-upgrades"

import "dotenv/config"

const config: HardhatUserConfig = {
    networks: {
        bscTestnet: {
            url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
            accounts: [process.env.TESTNETKEY as string],
        },
        bscMainnet: {
            url: "https://bsc-dataseed.bnbchain.org/",
            accounts: [
                process.env.MAINNETKEY as string, // developer
            ],
        },
    },
    etherscan: {
        apiKey: {
            bscTestnet: process.env.TESTNETAPI as string,
            bscMainnet: process.env.MAINNETAPI as string,
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.8.19",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.8.12",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    mocha: {
        timeout: 40000,
    },
}

export default config
