// import { expect } from "chai"
// import { ethers } from "hardhat"

// let usdtToken: any
// let vnstToken: any

// describe("VNST", function () {
//     this.beforeAll(async function () {
//         const USDT = await ethers.getContractFactory("USDT")
//         usdtToken = await USDT.deploy()

//         const VNST = await ethers.getContractFactory("VNST")
//         vnstToken = await VNST.deploy(usdtToken.target)

//         const VNST_ADDRESS = await vnstToken.getAddress()
//         console.log("VNST deployed to:", VNST_ADDRESS)

//         await usdtToken.approve(VNST_ADDRESS, BigInt(10000000 * 10 ** 10))
//     })
//     it("Mint function work correctly", async () => {
//         // const amountMint = ethers.parseEther("1000")

//         // await vnstToken.mint(amountMint)

//         // r_center_after_mint = await vnstToken.r_center()
//         console.log("r_center before V2 deployed:", await vnstToken.r_center())
//         console.log("vnst_pool before V2 deployed:", await vnstToken.vnst_pool())
//         console.log("usdt_pool before V2 deployed:", await vnstToken.usdt_pool())
//         // expect(r_center_after_mint).to.equal(BigInt(24900))
//         expect(1).to.equal(1)
//     })

//     it("Check if Pauseable", () => {
//         expect(1).equal(1)
//     })
// })
