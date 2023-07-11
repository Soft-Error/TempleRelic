import { ethers } from "hardhat";
import { BigNumber, Signer } from "ethers";
import { TypedDataDomain, TypedDataField, TypedDataSigner } from "@ethersproject/abstract-signer";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

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
        await ethers.provider.getBlockNumber();
        let currentTimestamp = await ethers.provider.getBlockNumber();
        const account = await add2.getAddress();
        const deadline = currentTimestamp - 600;
        const nonce = 1;
        const MintRequest = [account, deadline, nonce];

        const data = {
            types: {
              EIP712Domain: [
                { name: "name", type: "string" },
                { name: "version", type: "string" },
                { name: "chainId", type: "uint256" },
              ],
              MintRequest: [
                { name: "account", type: "address" },
                { name: "deadline", type: "uint256" },
                { name: "nonce", type: "uint256" },
              ],
            },
            domain: {
              name: "PathOfTheTemplarShard",
              version: "1",
              chainId: 421613,
            },
            primaryType: "MintRequest",
            message: {
              account: await add2.getAddress(),
              deadline: currentTimestamp - 600,
              nonce: 1,
            },
          };
        
        const signature = add2._signTypedData (
            data.domain,
            data.types,
            data.message
        );

        await pathOfTheTemplarShard.setMinter(await add2.getAddress(), true);
        await pathOfTheTemplarShard.connect(add2).mintShard(MintRequest, signature, 2);
        });

});
