import { ethers } from "hardhat";
import { BigNumber, Signer } from "ethers";
import { TypedDataDomain, TypedDataField, TypedDataSigner } from "@ethersproject/abstract-signer";
import { expect } from "chai";
import {
  PathOfTheTemplarShard, PathOfTheTemplarShard__factory,
  Relic, Relic__factory,
  Shards, Shards__factory,
} from "../typechain";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import path from "path";

let owner: Signer;
let add2: Signer;
let add3: Signer;
let add4: Signer;
let pathOfTheTemplarShard: PathOfTheTemplarShard;
let relic: Relic;
let shards: Shards;
let SHARD_ID: number[] = [2, 3, 4, 5, 6];
let ENCLAVE: string[] = [
    "",
    "chaosEnclave",
    "mysteryEnclave",
    "logicEnclave",
    "structureEnclave",
    "orderEnclave"
];


describe("PathOfTheTemplarShard", async () => {

    before( async () => {
        [owner, add2, add3, add4] = await ethers.getSigners();
    });

    async function setup() {
        relic = await new Relic__factory(owner).deploy();
        shards = await new Shards__factory(owner).deploy();
        pathOfTheTemplarShard = await new PathOfTheTemplarShard__factory(owner).deploy();

        return {
            relic,
            shards,
            pathOfTheTemplarShard,
        }
    }

    beforeEach( async () => {
        ({
            relic,
            shards,
            pathOfTheTemplarShard,
        } = await loadFixture(setup));
    });

    it("Check if deployer is owner", async function () {
        expect(await pathOfTheTemplarShard.owner()).to.equal(await owner.getAddress());
    });

    it("Check if mapping of enclave to Shard Id is correct", async function () {
        await pathOfTheTemplarShard.establishMapping();
    
        for (let i = 2; i < SHARD_ID.length; i++) {
          expect(await pathOfTheTemplarShard.getEnclaveForShard(SHARD_ID[i])).to.equal(ENCLAVE[i]);
        }
    });

    it("Check if mint request is relayed successfully", async function () {

        const provider = ethers.getDefaultProvider();
        const block = await provider.getBlock(await provider.getBlockNumber());
        const now = block.timestamp;

        const deadline = now + 3600;

        const request = {
            account: await add2.getAddress(),
            nonce: 1,
            deadline: deadline,
        };

        console.log("Request: ", request);

        const signature = await add2.signMessage(
          ethers.utils.arrayify(
            ethers.utils.solidityKeccak256(
              ["address", "uint256", "uint256"],
              [request.account, request.nonce, request.deadline]
            )
          )
        );
        
        // Print the signature
        console.log("Signature: ", signature);

        await expect(
            pathOfTheTemplarShard.relayMintRequestFor(request, signature)
        )
            .to.emit(pathOfTheTemplarShard, 'MinterSet')
            .withArgs(request.account, true);
      
        // Print the minter status of the account
        console.log("Minter status: ", await pathOfTheTemplarShard.minters(request.account));
      
        expect(await pathOfTheTemplarShard.minters(request.account)).to.equal(true);
      });

    it("Check if owner can set Minter Role", async function () {
        const account = await add2.getAddress();
        const value = true;
      
        await expect(
            pathOfTheTemplarShard.connect(owner).setMinter(account, value)
        )
            .to.emit(pathOfTheTemplarShard, 'MinterSet')
            .withArgs(account, value);
      
        expect(await pathOfTheTemplarShard.minters(account)).to.equal(value);

      });

      it("Check if message signer can mint", async function () {
        const signer = await add2.getAddress();
        const random = await add3.getAddress();
        const shardIndex = [];
        const invalidShardIndex = [];
        for (let i = 2; i <= 6; i++)
            shardIndex.push(SHARD_ID[i]);
            invalidShardIndex.push(SHARD_ID[i] + 1);
            invalidShardIndex.push(SHARD_ID[i] - 1);

        await pathOfTheTemplarShard.mintShard(shardIndex);

        await expect(pathOfTheTemplarShard.connect(random)).to.emit(shards, 'PartnerMint')
            .withArgs(add3.getAddress(), SHARD_ID[shardIndex], 1, "");

        await expect(pathOfTheTemplarShard.mintShard(invalidShardIndex)).to.be.revertedWith("InvalidMint");

        expect(await pathOfTheTemplarShard.minters((shardIndex))).to.equal(true);
      });
      
});
