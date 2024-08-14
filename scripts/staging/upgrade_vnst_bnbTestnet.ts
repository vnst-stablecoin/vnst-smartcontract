import hre from "hardhat"
import "dotenv/config"

async function main() {
    const VNST = await hre.ethers.getContractFactory("VNSTProtocol")
    console.log("Upgrading VNST ...")
    const vnst = await hre.upgrades.upgradeProxy(process.env.PROXYTESTNETADDRESS as string, VNST)
    console.log("VNST deployed to:", vnst.target)
    console.log("Adding mod for CMS ...")
    await vnst.addMod(process.env.TESTNETMOD)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
