import hre from "hardhat"

async function main() {
    console.log("Deploying VNST ...")
    const vnst = await hre.ethers.deployContract("VNST", { gasLimit: 0x1000000 })
    await vnst.waitForDeployment()

    console.log("VNST Deployed at:", vnst.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
