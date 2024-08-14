import hre from "hardhat"

async function main() {
    const USDT = await hre.ethers.getContractFactory("USDT")
    console.log("Deploying USDT ...")
    const usdt = await USDT.deploy()
    console.log("USDT deployed to:", usdt.target)

    const VNSTProxy = await hre.ethers.getContractFactory("VNSTProxy")
    console.log("Deploying VNST Proxy ...")

    const vnstProxy = await hre.upgrades.deployProxy(VNSTProxy, [usdt.target], {
        kind: "uups",
    })
    await vnstProxy.waitForDeployment();


    const VNST_PROXY_ADDRESS = await vnstProxy.getAddress()
    console.log("VNST Proxy deployed to:", VNST_PROXY_ADDRESS)

    const VNST = await hre.ethers.getContractFactory("VNSTProtocol")
    console.log("Deploying VNST ...")
    const vnst = await hre.upgrades.upgradeProxy(vnstProxy, VNST)
    console.log("VNST deployed to:", vnst.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
