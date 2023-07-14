import { ethers } from "hardhat";
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

type MySigner = SignerWithAddress & TypedDataSigner;

let owner: MySigner;
let add2: MySigner;
let add3: MySigner;
let add4: MySigner;
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

      it("Check if a signer that is not whitelisted minter produces an invalid signature", async function () {

      });

      it("Check if message signer can mint", async function () {
        let currentTimestamp = await ethers.provider.getBlockNumber();
        const account = await add3.getAddress();
        const deadline = 168317755900;
        console.dir({deadline, currentTimestamp});
        const nonce = await pathOfTheTemplarShard.nonces(account);
        const MintRequest: PathOfTheTemplarShard.MintRequestStruct = {account, deadline, nonce};

        const data = {
          types: {

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
              account: account,
              deadline: deadline,
              nonce: nonce,
            },
          };

        const signature = await add2._signTypedData(data.domain, data.types, data.message);

        await pathOfTheTemplarShard.setMinter(await add2.getAddress(), true);
        await pathOfTheTemplarShard.connect(add3).mintShard(MintRequest, signature, 2);
        });

});
