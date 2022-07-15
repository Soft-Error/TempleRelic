const { expect } = require("chai");
const { ethers } = require("hardhat");

let Relic, relic, Items, items, Whitelister, whitelister;
let owner, add1, add2; 

describe("Greeter", function () {
  beforeEach("Initialise",async ()=>{
    [owner,add1, add2] = await ethers.getSigners();
    Relic = await ethers.getContractFactory("Relic");
    relic = await Relic.deploy();

    Items = await ethers.getContractFactory("RelicItems");
    items = await Items.deploy();

    Whitelister = await ethers.getContractFactory("DummyWhitelister");
    whitelister = await Whitelister.deploy();

    await relic.setItemContract(items.address);
    await items.setRelic(relic.address);
    await items.addWhitelister(whitelister.address);
    // await relic.whitelistTemplar(add1.address);
    await whitelister.setRelicItems(items.address);
    await whitelister.whitelist(add1.address,0);

    await relic.setThresholds([0,10,100,1000,10000]);

  });

  xit("should mint", async ()=>{
    await relic.connect(add1).mintRelic(1);
    await items.connect(add1).mintFromUser(0);

    console.log("add1 balance is ", await items.balanceOf(add1.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));
    await relic.connect(add1).batchEquipItems(0, [0],[1]);
    console.log("add1 balance is ", await items.balanceOf(add1.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

    console.log("Transfering to add2");
    await relic.connect(add1)["safeTransferFrom(address,address,uint256)"](add1.address,add2.address,0);
    console.log("add1 balance is ", await items.balanceOf(add1.address,0));
    console.log("add2 balance is ", await items.balanceOf(add2.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

    console.log("Unequipping");
    await relic.connect(add2).batchUnequipItems(0, [0],[1]);
    console.log("add1 balance is ", await items.balanceOf(add1.address,0));
    console.log("add2 balance is ", await items.balanceOf(add2.address,0));
    console.log("relic balance is: ", await relic.getBalance(0,0));

  });

  it("should level up", async () =>{
    await relic.connect(add1).mintRelic(1);
    await items.connect(add1).mintFromUser(0);

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

  });
});
