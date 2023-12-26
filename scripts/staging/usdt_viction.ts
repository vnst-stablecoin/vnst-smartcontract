import hre from "hardhat"

async function main() {
    const USDT = await hre.ethers.getContractFactory("USDT")
    const usdt = USDT.attach(
        "0x69d75da9e018f3E624c173358f47fffCdBaB5362", // The deployed contract address
    )

    // console.log(await vnst.addMod(process.env.TESTNETMOD, { gasLimit: 0x1000000 }))
    // console.log(await vnst.mint(hre.ethers.parseEther("2000"), { gasLimit: 0x1000000 }))
    console.log(
        await usdt.approve("0xEf5fFe1A794FB4ed2Cf2fF0C0334b50CF1E98697", hre.ethers.parseEther("10000000"), {
            gasLimit: 0x1000000,
        }),
    )
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
