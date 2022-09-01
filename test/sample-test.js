const { expect } = require("chai");
const { ethers } = require("hardhat");

let Relic, relic, Shards, shards, Whitelister, whitelister, TempleWL, templeWL;
let owner, add1, add2; 

describe("Greeter", function () {
  beforeEach("Initialise",async ()=>{
    [owner,add1, add2] = await ethers.getSigners();
    Relic = await ethers.getContractFactory("Relic");
    relic = await Relic.deploy();

    Shards = await ethers.getContractFactory("Shards");
    shards = await Shards.deploy();

    Whitelister = await ethers.getContractFactory("DummyWhitelister");
    whitelister = await Whitelister.deploy();

    TempleWL = await ethers.getContractFactory("TempleRelicWhitelister");
    templeWL = await TempleWL.deploy();

    await relic.setShardContract(shards.address);
    await shards.setRelic(relic.address);
    await shards.addWhitelister(whitelister.address);
    // await relic.whitelistTemplar(add1.address);
    await whitelister.setRelicShards(shards.address);
    await whitelister.whitelist(add1.address,0);

    await relic.setThresholds([10,100,1000,10000]);

    await relic.setTempleWhitelister(templeWL.address);

  });

  xit("should mint", async ()=>{
    await relic.connect(add1).mintRelic(1);
    await shards.connect(add1).mintFromUser(0);

    console.log("add1 balance is ", await shards.balanceOf(add1.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));
    await relic.connect(add1).batchEquipshards(0, [0],[1]);
    console.log("add1 balance is ", await shards.balanceOf(add1.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

    console.log("Transfering to add2");
    await relic.connect(add1)["safeTransferFrom(address,address,uint256)"](add1.address,add2.address,0);
    console.log("add1 balance is ", await shards.balanceOf(add1.address,0));
    console.log("add2 balance is ", await shards.balanceOf(add2.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

    console.log("Unequipping");
    await relic.connect(add2).batchUnequipshards(0, [0],[1]);
    console.log("add1 balance is ", await shards.balanceOf(add1.address,0));
    console.log("add2 balance is ", await shards.balanceOf(add2.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

  });

  xit("should level up", async () =>{
    await relic.connect(add1).mintRelic(1);
    await shards.connect(add1).mintFromUser(0);

    let infos = await relic.getRelicInfos(0);
    console.log("relic infos: ", infos);
    let currXP = await relic.getRelicXP(0);
    console.log("currXP: ", currXP);

    await relic.givePoints(12,0);
    infos = await relic.getRelicInfos(0);
    console.log("relic infos: ", infos);
    currXP = await relic.getRelicXP(0);
    console.log("currXP: ", currXP);

    await relic.givePoints(2400,0);
    infos = await relic.getRelicInfos(0);
    console.log("relic infos: ", infos);
    currXP = await relic.getRelicXP(0);
    console.log("currXP: ", currXP);

    await relic.givePoints(24000,0);
    infos = await relic.getRelicInfos(0);
    console.log("relic infos: ", infos);
    currXP = await relic.getRelicXP(0);
    console.log("currXP: ", currXP);

  });

  it("Should transmute", async () => {
    await templeWL.setRelic(relic.address);
    await templeWL.connect(add1).whitelistTemplar();

    await relic.connect(add1).mintRelic(1);
    console.log("1");
    await shards.createRecipe(0,[0],[1],[1],[2]);
    console.log("2");
    // mint stuff
    await shards.mint(add1.address, 0,1,"0x");
    console.log("3");
    let balance0 = await shards.balanceOf(add1.address, 0);
    console.log("balance0: ", balance0);
    let balance1 = await shards.balanceOf(add1.address, 1);
    console.log("balance1: ", balance1);

    await shards.connect(add1).transmute(0);

     balance0 = await shards.balanceOf(add1.address, 0);
    console.log("balance0: ", balance0);
     balance1 = await shards.balanceOf(add1.address, 1);
    console.log("balance1: ", balance1);

  });

});
