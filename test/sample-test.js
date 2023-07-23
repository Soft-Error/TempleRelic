const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let Relic, relic, Shards, shards, ShardMinter, shardMinter, TempleSacrifice, templeSacrifice, Dummycoin, dummycoin;
let owner, add1, add2, add3, add4, add5, add6, add7, add8, add9; 

let Test, test;

describe("Greeter", function () {
  beforeEach("Initialise",async ()=>{
    [owner,add1, add2, add3, add4, add5, add6, add7, add8, add9] = await ethers.getSigners();
    Relic = await ethers.getContractFactory("Relic");
    relic = await Relic.deploy();

    Shards = await ethers.getContractFactory("Shards");
    shards = await Shards.deploy();

    Test = await ethers.getContractFactory("Splitter");
    test = await Test.deploy();

    ShardMinter = await ethers.getContractFactory("Apocrypha");
    shardMinter = await ShardMinter.deploy();

    TempleSacrifice = await ethers.getContractFactory("TempleSacrifice");
    templeSacrifice = await TempleSacrifice.deploy();

    Dummycoin = await ethers.getContractFactory("dummycoin");
    dummycoin = await Dummycoin.deploy();

    await relic.setShardContract(shards.address);
    await relic.setThresholds([1000,10000,100000,1000000]); 
    await relic.setTempleWhitelister(templeSacrifice.address);
    
    await shards.setRelic(relic.address);
    await shards.addPartner(shardMinter.address, true);
    await shards.whiteListItemsForPartner(shardMinter.address, [0,1], true);
    // await relic.whitelistTemplar(add1.address);
    await shardMinter.setRelicShards(relic.address,shards.address);

    await dummycoin.connect(add1).getmooni();

    await templeSacrifice.setAddresses(relic.address, dummycoin.address);
    let timmme = (await ethers.provider.getBlock("latest")).timestamp;
    await templeSacrifice.setOriginTime(timmme);

  });

  it("Should mint relic, then a shard", async ()=>{

    // sacrifice Temple and get whitelisted
    console.log("Get price: ", await templeSacrifice.getPrice());
    
    await dummycoin.connect(add1).approve(templeSacrifice.address, "1000000000000000000000");
    await templeSacrifice.connect(add1).sacrifice();

    // mint relic
    await relic.connect(add1).mintRelic(0);
    console.log("balance Relic: ", await relic.balanceOf(add1.address));

    // mint shard
    await shardMinter.connect(add1).mintShard();
    console.log("balance Shard 0: ", await shards.balanceOf(add1.address, 1));

  });


});
