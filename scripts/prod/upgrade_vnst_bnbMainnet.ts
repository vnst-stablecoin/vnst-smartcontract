import hre from "hardhat"
import "dotenv/config"

async function main() {
    const VNST = await hre.ethers.getContractFactory("VNSTProtocol")
    console.log("Upgrading VNST ...")
    const vnst = await hre.upgrades.upgradeProxy(process.env.PROXYMAINNETADDRESS as string, VNST)
    console.log("VNST deployed to:", vnst.target)

    console.log("Reminder to set Max Redeem Limit after upgrade")
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
