import hre from "hardhat"

async function main() {
    const VNSC = await hre.ethers.getContractFactory("VNSC")
    const deploy = await VNSC.deploy("0xFaE122E3AB1e7C6aC42C1901fA9cEAb4C9c3E75a")

    await deploy.deployed()

    console.log("vnsc deployed to:", deploy.address)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
