import hre from "hardhat"

async function main() {
    // const VNST = await hre.ethers.getContractFactory("VNSTProtocol")
    // console.log("Upgrading VNST ...")
    // const vnst = await hre.upgrades.upgradeProxy(process.env.PROXYTESTNETADDRESS as string, VNST)
    // console.log("VNST deployed to:", vnst.target)
    // console.log("Adding mod for CMS ...")
    // await vnst.addMod(process.env.TESTNETMOD)

    const VNST = await hre.ethers.getContractFactory("VNSTProtocol")
    const vnst = VNST.attach(
        "0xEf5fFe1A794FB4ed2Cf2fF0C0334b50CF1E98697", // The deployed contract address
    )

    // console.log(await vnst.addMod(process.env.TESTNETMOD, { gasLimit: 0x1000000 }))
    // console.log(await vnst.mint(hre.ethers.parseEther("2000"), { gasLimit: 0x1000000 }))
    // console.log(await vnst.balanceOf(0x631dba1263e9bd9bd80833ab1aff8ab61841ee40))
    // const balance = await vnst.balanceOf(0x631dba1263e9bd9bd80833ab1aff8ab61841ee40)
    // console.log(balance)

    // console.log(await vnst.setMaxRedeemLimit(hre.ethers.parseEther("50000000000"), { gasLimit: 0x1000000 }))

    console.log(await vnst.redeem(hre.ethers.parseEther("100000"), { gasLimit: 0x1000000 }))
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
