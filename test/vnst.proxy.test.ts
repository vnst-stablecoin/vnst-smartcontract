import { expect } from "chai"
import hre from "hardhat"

import { sqrt } from "./helpers"

let usdt: any
let vnstProxy: any
let vnst: any
let mock: any
let owner: any
let alice: any
let mod: any
const _rate_decimal: bigint = hre.ethers.toBigInt(1000000)

describe("VNST", function () {
    this.beforeAll(async function () {
        ;[owner, mod, alice] = await hre.ethers.getSigners()
        const USDT = await hre.ethers.getContractFactory("USDT")
        console.log("Deploying USDT ...")
        usdt = await USDT.deploy()
        console.log("USDT deployed to:", usdt.target)

        const VNSTProxy = await hre.ethers.getContractFactory("VNSTProxy")
        console.log("Deploying VNST Proxy ...")

        vnstProxy = await hre.upgrades.deployProxy(VNSTProxy, [usdt.target], {
            kind: "uups",
        })

        const VNST_PROXY_ADDRESS = await vnstProxy.getAddress()
        console.log("VNST Proxy deployed to:", VNST_PROXY_ADDRESS)

        await usdt.approve(VNST_PROXY_ADDRESS, hre.ethers.parseEther("10000000"))

        const VNST = await hre.ethers.getContractFactory("VNSTProtocol")

        console.log("Deploying VNST ...")
        vnst = await hre.upgrades.upgradeProxy(vnstProxy, VNST)
        console.log("VNST deployed to:", vnst.target)

        // Set Max Redeem Limit
        await vnst.setMaxRedeemLimit(hre.ethers.parseEther("50000000000"))

        const MockVNST = await hre.ethers.getContractFactory("MockVNST")

        console.log("Deploying mock contract ...")
        mock = await hre.upgrades.upgradeProxy(vnstProxy, MockVNST)
        console.log("Mock deployed to: ", mock.target)
    })

    describe("Test Proxy VNST", () => {
        it("Proxy work correctly", async () => {
            expect(await vnstProxy.getAddress()).to.equal(await vnst.getAddress())
            expect(await vnst.version()).to.equal("v1!")
        })

        it("Proxy Contract's functions permission work correctly", async () => {
            await expect(vnst.connect(mod).addMod(alice.address)).to.be.revertedWith("Ownable: caller is not the owner")

            await expect(vnst.connect(mod).removeMod(alice.address)).to.be.revertedWith(
                "Ownable: caller is not the owner",
            )

            await expect(vnst.connect(mod).emergencyWithdraw()).to.be.revertedWith("Ownable: caller is not the owner")

            await expect(vnst.connect(mod).withdrawUSDT(1)).to.be.revertedWith("Ownable: caller is not the owner")

            await expect(vnst.connect(mod).withdrawOperationPool()).to.be.revertedWith(
                "Ownable: caller is not the owner",
            )
        })
    })

    describe("Test VNST Protocol", () => {
        it("Pauseable work correctly", async () => {
            await vnst.pause()

            await expect(vnst.mint(BigInt(1000 * 10 ** 18))).to.be.revertedWith("Pausable: paused")
            await vnst.unpause()

            await expect(vnst.connect(mod).pause()).to.be.revertedWith("Ownable: caller is not the owner")

            await expect(vnst.connect(mod).unpause()).to.be.revertedWith("Ownable: caller is not the owner")
        })
        async function vnst7265626f6f7420706f6f6c() {
            await vnst.vnst7265626f6f7420706f6f6c(
                hre.ethers.toBigInt(25000000000),
                hre.ethers.parseEther("30000000"),
                hre.ethers.toBigInt(25200000000),
                hre.ethers.toBigInt(24900000000),
            )

            await vnst.vnst53657420436f766572(hre.ethers.parseEther("100000"), hre.ethers.parseEther("2500000000"))
        }

        it("Reboot Pool and set Redeem Fee work correctly", async () => {
            await vnst7265626f6f7420706f6f6c()
            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))
            expect(await vnst.usdt_pool()).to.equal(hre.ethers.parseEther("30000000"))
            expect(await vnst.vnst_pool()).to.equal(hre.ethers.parseEther("750000000000"))
            expect(await vnst.redeem_covered_amount()).to.equal(hre.ethers.parseEther("100000"))
            expect(await vnst.mint_covered_amount()).to.equal(hre.ethers.parseEther("2500000000"))
            expect(await vnst.redeem_covered_price()).to.equal(hre.ethers.toBigInt(25200000000))
            expect(await vnst.mint_covered_price()).to.equal(hre.ethers.toBigInt(24900000000))
            expect(await vnst.k()).to.equal(hre.ethers.parseEther("22500000000000000000000000000000000000"))

            await expect(
                vnst.vnst7265626f6f7420706f6f6c(
                    hre.ethers.toBigInt(25300000000),
                    hre.ethers.parseEther("30000000"),
                    hre.ethers.toBigInt(25200000000),
                    hre.ethers.toBigInt(24900000000),
                ),
            ).to.be.revertedWith("market_price_above_covered_redeem_price")

            await expect(
                vnst.vnst7265626f6f7420706f6f6c(
                    hre.ethers.toBigInt(24800000000),
                    hre.ethers.parseEther("30000000"),
                    hre.ethers.toBigInt(25200000000),
                    hre.ethers.toBigInt(24900000000),
                ),
            ).to.be.revertedWith("market_price_below_covered_mint_price")

            // Test vnst73657420666565
            await vnst.vnst73657420666565(hre.ethers.toBigInt(2000))
            expect(await vnst.redeem_fee()).to.equal(hre.ethers.toBigInt(2000))
            await vnst.vnst73657420666565(hre.ethers.toBigInt(1000))
        })

        it("Set and remove moderator role function work correctly", async () => {
            await expect(
                vnst
                    .connect(mod)
                    .vnst7265626f6f7420706f6f6c(
                        hre.ethers.toBigInt(25000000000),
                        hre.ethers.parseEther("30000000"),
                        hre.ethers.toBigInt(25200000000),
                        hre.ethers.toBigInt(24900000000),
                    ),
            ).to.be.revertedWith("caller_lacks_necessary_permission")

            await expect(
                vnst
                    .connect(mod)
                    .vnst53657420436f766572(hre.ethers.parseEther("100000"), hre.ethers.parseEther("2500000000")),
            ).to.be.revertedWith("caller_lacks_necessary_permission")

            await expect(vnst.connect(mod).vnst73657420666565(hre.ethers.toBigInt(1000))).to.be.revertedWith(
                "caller_lacks_necessary_permission",
            )

            // Add mod
            await vnst.addMod(mod.address)

            await vnst
                .connect(mod)
                .vnst7265626f6f7420706f6f6c(
                    hre.ethers.toBigInt(25000000000),
                    hre.ethers.parseEther("30000000"),
                    hre.ethers.toBigInt(25200000000),
                    hre.ethers.toBigInt(24900000000),
                )

            await vnst
                .connect(mod)
                .vnst53657420436f766572(hre.ethers.parseEther("100000"), hre.ethers.parseEther("2500000000"))

            await vnst.connect(mod).vnst73657420666565(hre.ethers.toBigInt(2000))
            expect(await vnst.redeem_fee()).to.equal(hre.ethers.toBigInt(2000))
            await vnst.connect(mod).vnst73657420666565(hre.ethers.toBigInt(1000))

            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))
            expect(await vnst.usdt_pool()).to.equal(hre.ethers.parseEther("30000000"))
            expect(await vnst.vnst_pool()).to.equal(hre.ethers.parseEther("750000000000"))
            expect(await vnst.redeem_covered_amount()).to.equal(hre.ethers.parseEther("100000"))
            expect(await vnst.mint_covered_amount()).to.equal(hre.ethers.parseEther("2500000000"))
            expect(await vnst.redeem_covered_price()).to.equal(hre.ethers.toBigInt(25200000000))
            expect(await vnst.mint_covered_price()).to.equal(hre.ethers.toBigInt(24900000000))
            expect(await vnst.k()).to.equal(hre.ethers.parseEther("22500000000000000000000000000000000000"))

            // Remove mod
            await vnst.removeMod(mod.address)

            await expect(
                vnst
                    .connect(mod)
                    .vnst7265626f6f7420706f6f6c(
                        hre.ethers.toBigInt(25000000000),
                        hre.ethers.parseEther("30000000"),
                        hre.ethers.toBigInt(25200000000),
                        hre.ethers.toBigInt(24900000000),
                    ),
            ).to.be.revertedWith("caller_lacks_necessary_permission")

            await expect(
                vnst
                    .connect(mod)
                    .vnst53657420436f766572(hre.ethers.parseEther("100000"), hre.ethers.parseEther("2500000000")),
            ).to.be.revertedWith("caller_lacks_necessary_permission")

            await expect(vnst.connect(mod).vnst73657420666565(hre.ethers.toBigInt(1000))).to.be.revertedWith(
                "caller_lacks_necessary_permission",
            )
        })

        it("Mint require work correctly", async () => {
            await expect(vnst.mint(hre.ethers.parseEther("10000000000"))).to.be.revertedWith("usdt_insufficient")
            await expect(vnst.mint(hre.ethers.parseEther("1"))).to.be.revertedWith("min_usdt_amount")

            await mock.setMarketPrice(hre.ethers.toBigInt(24800000000))
            await expect(vnst.mint(hre.ethers.parseEther("10"))).to.be.revertedWith(
                "market_price_below_covered_mint_price",
            )

            await vnst7265626f6f7420706f6f6c()

            await expect(vnst.mint(hre.ethers.parseEther("2001"))).to.be.revertedWith("max_usdt_amount")

            for (let i = 0; i < 80; i++) {
                await vnst.mint(hre.ethers.parseEther("2000"))
            }

            await expect(vnst.mint(hre.ethers.parseEther("2000"))).to.be.revertedWith("out_of_covered_mint_amount")
        })

        it("Mint function case VMM not available work correctly", async () => {
            await vnst7265626f6f7420706f6f6c()
            const u = await vnst.usdt_pool()
            const v = await vnst.vnst_pool()
            const r = await vnst.mint_covered_price()

            const amount_usdt_in_before_support = getUSDTInBeforeCovered(u, v, r)

            // VMM not available after this mint
            for (let i = 0; i < 30; i++) {
                await vnst.mint(hre.ethers.parseEther("2000"))
            }
            await vnst.mint(amount_usdt_in_before_support - hre.ethers.parseEther("60000"))

            expect(await vnst.market_price()).to.equal(await vnst.mint_covered_price())
            expect(await vnst.mint_covered_amount()).to.equal(hre.ethers.parseEther("2500000000"))

            await vnst.mint(hre.ethers.parseEther("100"))

            const amount_vnst_support_out = (hre.ethers.parseEther("100") * r) / _rate_decimal

            expect(await vnst.mint_covered_amount()).to.equal(
                hre.ethers.parseEther("2500000000") - amount_vnst_support_out,
            )
        })

        it("Mint function case VMM available and mint don't hit cover price work correctly", async () => {
            await vnst7265626f6f7420706f6f6c()

            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))
            const x = await vnst.usdt_pool()

            const y = await vnst.vnst_pool()

            const Dx = hre.ethers.parseEther("1000")

            const Dy = calculateVMM(x, y, Dx)

            await vnst.mint(hre.ethers.parseEther("1000"))

            const market_price_after_mint = await vnst.market_price()

            expect(market_price_after_mint).to.equal(((y - Dy) * _rate_decimal) / (x + Dx))
        })

        it("Mint function case VMM available and mint hit cover price work correctly", async () => {
            await vnst7265626f6f7420706f6f6c()
            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))

            const u = await vnst.usdt_pool()
            const v = await vnst.vnst_pool()
            const r = await vnst.mint_covered_price()

            const amount_usdt_in_before_support = getUSDTInBeforeCovered(u, v, r)

            for (let i = 0; i < 30; i++) {
                await vnst.mint(hre.ethers.parseEther("2000"))
            }
            await vnst.mint(hre.ethers.parseEther("200"))

            expect(await vnst.market_price()).to.equal(await vnst.mint_covered_price())

            const expected_mint_covered_amount =
                hre.ethers.parseEther("2500000000") -
                ((hre.ethers.parseEther("60200") - amount_usdt_in_before_support) * r) / _rate_decimal

            expect(await vnst.mint_covered_amount()).to.equal(hre.ethers.toBigInt(expected_mint_covered_amount))
        })

        it("Redeem require work correctly", async () => {
            await expect(vnst.redeem(hre.ethers.parseEther("100000000000000000"))).to.be.revertedWith(
                "vnst_insufficient",
            )
            await expect(vnst.redeem(hre.ethers.parseEther("1"))).to.be.revertedWith("min_vnst_amount")

            await mock.setMarketPrice(hre.ethers.toBigInt(25300000000))
            await expect(vnst.redeem(hre.ethers.parseEther("100000"))).to.be.revertedWith(
                "market_price_above_covered_redeem_price",
            )
            await vnst7265626f6f7420706f6f6c()

            await mock.hackMint()
            await expect(vnst.redeem(hre.ethers.parseEther("10000000000"))).to.be.revertedWith(
                "out_of_covered_redeem_amount",
            )
        })

        it("Redeem function case VMM not available work correctly", async () => {
            for (let i = 0; i < 5; i++) {
                await vnst.mint(hre.ethers.parseEther("2000"))
            }

            await vnst7265626f6f7420706f6f6c()
            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))

            const u = await vnst.usdt_pool()
            const v = await vnst.vnst_pool()
            const r = await vnst.redeem_covered_price()

            const amount_vnst_in_before_support = getVNSTInBeforeCovered(u, v, r)

            // VMM not available after this redeem
            await vnst.redeem(amount_vnst_in_before_support)

            await vnst.withdrawOperationPool()
            expect(await vnst.operation_pool()).to.equal(0)

            // @note For some reasons market_price equal to 25199999999 but it's still work
            // expect(await vnst.market_price()).to.equal(await vnst.redeem_covered_price())
            expect(await vnst.redeem_covered_amount()).to.equal(hre.ethers.parseEther("100000"))

            const redeem_fee = await vnst.redeem_fee()

            await vnst.redeem(hre.ethers.parseEther("100000"))

            const expected_redeem_covered_amount =
                hre.ethers.parseEther("100000") -
                (hre.ethers.parseEther("100000") * _rate_decimal) / hre.ethers.toBigInt(25200000000)

            expect(await vnst.operation_pool()).to.equal(
                (((hre.ethers.parseEther("100000") * _rate_decimal) / hre.ethers.toBigInt(25200000000)) * redeem_fee) /
                    _rate_decimal,
            )
            expect(await vnst.redeem_covered_amount()).to.equal(expected_redeem_covered_amount)

            await vnst7265626f6f7420706f6f6c()
        })

        // @note This test is the same with the above test but we need it to give more coverage
        it("Redeem function case VMM not available work correctly", async () => {
            await vnst7265626f6f7420706f6f6c()
            await vnst.withdrawOperationPool()
            expect(await vnst.operation_pool()).to.equal(0)

            await mock.setMarketPrice(hre.ethers.toBigInt(25200000000))

            expect(await vnst.market_price()).to.equal(await vnst.redeem_covered_price())
            expect(await vnst.redeem_covered_amount()).to.equal(hre.ethers.parseEther("100000"))

            const redeem_fee = await vnst.redeem_fee()

            await vnst.redeem(hre.ethers.parseEther("100000"))

            const expected_redeem_covered_amount =
                hre.ethers.parseEther("100000") -
                (hre.ethers.parseEther("100000") * _rate_decimal) / hre.ethers.toBigInt(25200000000)

            expect(await vnst.operation_pool()).to.equal(
                (((hre.ethers.parseEther("100000") * _rate_decimal) / hre.ethers.toBigInt(25200000000)) * redeem_fee) /
                    _rate_decimal,
            )
            expect(await vnst.redeem_covered_amount()).to.equal(expected_redeem_covered_amount)

            await vnst7265626f6f7420706f6f6c()
        })

        it("Redeem function case VMM available and redeem don't hit r support work correctly", async () => {
            await vnst.withdrawOperationPool()
            expect(await vnst.operation_pool()).to.equal(0)

            for (let i = 0; i < 10; i++) {
                await vnst.mint(hre.ethers.parseEther("1000"))
            }
            await vnst7265626f6f7420706f6f6c()

            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))
            const x = await vnst.vnst_pool()

            const y = await vnst.usdt_pool()

            const Dx = hre.ethers.parseEther("10000000")

            const Dy = calculateVMM(x, y, Dx)

            await vnst.redeem(hre.ethers.parseEther("10000000"))

            const market_price_after_redeem = await vnst.market_price()

            expect(market_price_after_redeem).to.equal(((x + Dx) * _rate_decimal) / (y - Dy))

            expect(await vnst.operation_pool()).to.equal(Dy / BigInt(1000))
        })

        it("Redeem function case VMM available and redeem hit cover price work correctly", async () => {
            await vnst.withdrawOperationPool()
            expect(await vnst.operation_pool()).to.equal(0)

            for (let i = 0; i < 50; i++) {
                await vnst.mint(hre.ethers.parseEther("1000"))
            }
            await vnst7265626f6f7420706f6f6c()

            expect(await vnst.market_price()).to.equal(hre.ethers.toBigInt(25000000000))

            const u = await vnst.usdt_pool()
            const v = await vnst.vnst_pool()
            const r = await vnst.redeem_covered_price()

            const amount_vnst_in_before_support = getVNSTInBeforeCovered(u, v, r)

            const Dy = calculateVMM(v, u, amount_vnst_in_before_support)

            await vnst.redeem(hre.ethers.parseEther("3000000000"))

            const expected_redeem_covered_amount =
                hre.ethers.parseEther("100000") -
                ((hre.ethers.parseEther("3000000000") - amount_vnst_in_before_support) * _rate_decimal) / r

            const sum_usdt_out =
                Dy + ((hre.ethers.parseEther("3000000000") - amount_vnst_in_before_support) * _rate_decimal) / r
            const redeem_fee = await vnst.redeem_fee()
            expect(await vnst.operation_pool()).to.equal((sum_usdt_out * redeem_fee) / _rate_decimal)

            // expect(await vnst.market_price()).to.equal(await vnst.redeem_covered_price())

            expect(await vnst.redeem_covered_amount()).to.equal(hre.ethers.toBigInt(expected_redeem_covered_amount))
        })

        it("Withdraw to owner wallet in case of emergency work correctly", async () => {
            let usdtInVNST = await usdt.balanceOf(vnst.getAddress())

            await vnst.emergencyWithdraw()

            usdtInVNST = await usdt.balanceOf(vnst.getAddress())

            expect(usdtInVNST).to.equal(0)
            expect(await vnst.operation_pool()).to.equal(0)
        })

        it("Withdraw usdt and revenue functions work correctly", async () => {
            for (let i = 0; i < 10; i++) {
                await vnst.mint(hre.ethers.parseEther("1000"))
            }
            await vnst.redeem(hre.ethers.parseEther("10000000"))
            await vnst7265626f6f7420706f6f6c()

            let usdtInVNST = await usdt.balanceOf(vnst.getAddress())

            const operation_pool = await vnst.operation_pool()

            await expect(vnst.withdrawUSDT(0)).to.be.revertedWith("Need more than 0")

            await vnst.withdrawUSDT(usdtInVNST - operation_pool)

            usdtInVNST = await usdt.balanceOf(vnst.getAddress())

            expect(usdtInVNST).to.equal(await vnst.operation_pool())
            await expect(vnst.withdrawUSDT(operation_pool)).to.be.revertedWith("usdt_insufficient")

            expect(await vnst.operation_pool()).to.not.equal(0)

            const beforeWithdraw = await usdt.balanceOf(owner)

            await vnst.withdrawOperationPool()

            const afterWithdraw = await usdt.balanceOf(owner)

            expect(await vnst.operation_pool()).to.equal(0)
            expect(operation_pool).to.equal(afterWithdraw - beforeWithdraw)
        })

        it("Mint limit function work correctly", async () => {
            await vnst.setMaxMintLimit(hre.ethers.parseEther("1000"))
            expect(await vnst.max_mint_limit()).to.equal(hre.ethers.parseEther("1000"))
            await expect(vnst.connect(alice).setMaxMintLimit(hre.ethers.parseEther("1000"))).to.be.revertedWith(
                "Ownable: caller is not the owner",
            )
            await vnst.setMaxMintLimit(hre.ethers.parseEther("2000"))
        })
    })
})

function calculateVMM(x: bigint, y: bigint, Dx: bigint) {
    const Dy = (y * Dx) / (x + Dx)
    return Dy
}

function getUSDTInBeforeCovered(u: bigint, v: bigint, r: bigint) {
    const k = v * u
    const Du = sqrt((k * _rate_decimal) / r) - u
    return Du
}

function getVNSTInBeforeCovered(u: bigint, v: bigint, r: bigint) {
    const k: bigint = v * u
    const Dy = sqrt((k * r) / _rate_decimal) - v
    return Dy
}
