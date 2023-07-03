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

let owner: Signer;
let add2: Signer;
let pathOfTheTemplarShard: PathOfTheTemplarShard;
let relic: Relic;
let shards: Shards;

describe("PathOfTheTemplarShard", async () => {

    before( async () => {
        [owner, add2] = await ethers.getSigners();
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

});
