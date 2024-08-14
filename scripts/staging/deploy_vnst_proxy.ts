import hre from "hardhat"
import "dotenv/config"

async function main() {
    const VNSTProxy = await hre.ethers.getContractFactory("VNSTProxy")
    console.log("Deploying VNST Proxy ...")

    const vnstProxy = await hre.upgrades.deployProxy(VNSTProxy, [process.env.USDTTESTNETADDRESS], {
        kind: "uups",
    })

    await vnstProxy.waitForDeployment();


    const VNST_PROXY_ADDRESS = await vnstProxy.getAddress()
    console.log("VNST Proxy deployed to:", VNST_PROXY_ADDRESS)

}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
