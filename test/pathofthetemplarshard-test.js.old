const { expect } = require("chai");
const { BigNumber, Signer } = require("ethers");
const { ethers } = require("hardhat");
const { keccak256, } = require('ethers/lib/utils');

describe("PathOfTheTemplarShard", function() {
    let owner;
    let add1, add2, add3, add4;
    let PathOfTheTemplarShard;
    let pathOfTheTemplarShard;
    let pathOfTheTemplarShardContract;
    let Relic;
    let relic;
    let Shards;
    let shards;
    let SHARD_ID;
    let ENCLAVE;
});

beforeEach("Initialize",async ()=>{
    [owner, add2] = await ethers.getSigners();
    Relic = await ethers.getContractFactory("Relic");
    relic = await Relic.deploy();

    Shards = await ethers.getContractFactory("Shards");
    shards = await Shards.deploy();

    PathOfTheTemplarShard = await ethers.getContractFactory("PathOfTheTemplarShard");
    pathOfTheTemplarShard = await PathOfTheTemplarShard.deploy();
    await pathOfTheTemplarShard.deployed();

    SHARD_ID = await pathOfTheTemplarShard.SHARD_ID();
    ENCLAVE = await pathOfTheTemplarShard.ENCLAVE();

    const SECONDS_IN_ONE_HOUR = 3600;
    const ALICE = add1;
    const BOB = add2;
    const CHARLIE = add3;
    const DAVE = add4;
});

it("Check if mapping of enclave to Shard Id is correct", async function () {
    await pathOfTheTemplarShardhardContract.establishMapping();

    for (let i = 1; i < SHARD_ID.length; i++) {
      expect(await pathOfTheTemplarShardshardContract.getEnclaveForShard(SHARD_ID[i])).to.equal(ENCLAVE[i]);
    }
});

it("Check if deployer is owner", async function () {
    expect(await pathOfTheTemplarShardshardContract.owner()).to.equal(owner.address);
});

it("Check if set minter can be performed by owner", async function () {
    expect(await pathOfTheTemplarShard.connect(BOB)).setMinter(BOB.address, true).to.be.revertedWith('Ownable: Caller is not owner');
    expect(await pathOfTheTemplarShard.connect(owner)).setMinter(ALICE.address, true).to.emit(pathOfTheTemplarShard, 'MinterSet').withArgs(ALICE.address, true);
});

it("Check if msg.sender can obtain minter role", async function () {
    expect(await pathOfTheTemplarShard.connnect(ALICE).setMinter(ALICE.address, true).to.emit(pathOfTheTemplarShard, 'Minter role', true));
});

it("Check if msg.sender can mint", async function () {
    expect(await pathOfTheTemplarShard.connect(ALICE.address).canMint(1));
});

const mintRequest = {
    account: ALICE.address,
    deadline: now + 3600,
    nonce: 0,
};

const domain = {
    name: "PathOfTheTemplarShard",
    version: "1",
    chainId: 421613,
    verifyingContract: pathOfTheTemplarShardContract.address,
};

const types = {
    EIP712Domain: [
        { name: "name", type: "string" },
        {name: "version", type: "string" },
        { name: "chainId", type: "uint256" },
        { name: "verifyingContract", type: "address" }
    ],
    MintRequest: [
        { name: 'account', type: 'address' },
        { name: 'deadline', type: 'uint256' },
        { name: 'nonce', type: 'uint256' }, 
    ]
};

const signature = await ALICE._signTypedData(domain, types, mintRequest);
await expect(pathOfTheTemplarShardContract.relayMintRequestFor(mintRequest, signature)).to.not.be.reverted;
