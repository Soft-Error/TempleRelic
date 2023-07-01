const { expect } = require("chai");
const { BigNumber, Signer } = require("ethers");
const { ethers } = require("hardhat");

let Relic, relic, Shards, shards, PartnerMinter, partnerMinter, TempleWL, templeWL, Dummycoin, dummycoin;
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

    PartnerMinter = await ethers.getContractFactory("PartnerMinter");
    partnerMinter = await PartnerMinter.deploy();

    PathOfTheTemplarShard = await ethers.getContractFactory("PathOfTheTemplarShard");
    pathOfTheTemplarShard = await PathOfTheTemplarShard.deploy();

    TempleWL = await ethers.getContractFactory("TempleSacrifice");
    templeWL = await TempleWL.deploy();

    Dummycoin = await ethers.getContractFactory("dummycoin");
    dummycoin = await Dummycoin.deploy();

    await relic.setShardContract(shards.address);
    await relic.setThresholds([1000,10000,100000,1000000]); 
    await relic.setTempleWhitelister(templeWL.address);
    
    await shards.setRelic(relic.address);
    await shards.addPartner(partnerMinter.address, true);
    await shards.whiteListItemsForPartner(partnerMinter.address, [0,1], true);
    // await relic.whitelistTemplar(add1.address);
    await partnerMinter.setRelicShards(shards.address);

    await dummycoin.connect(add1).getmooni(10);

    await templeWL.setAddresses(relic.address, dummycoin.address);
    let timmme = (await ethers.provider.getBlock("latest")).timestamp;
    await templeWL.setOriginTime(timmme);

  });

  it("should mint", async ()=>{
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

  xit("Should transmute", async () => {
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
    console.log("balance0: ", await shards.balanceOf(add1.address, 0));
     balance1 = await shards.balanceOf(add1.address, 1);
    console.log("balance1: ", balance1);

  });

  xit("Should sign and mint and transmute", async ()=>{

    await shards.createRecipe(0,[0,1],[1,1],[2],[1]);

    const allowlistAddresses = [
      '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
      '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
      '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
      '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65'
    ];

    const owner = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
    const code = allowlistAddresses[0];
    const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

    const signer = new ethers.Wallet(privateKey);
    console.log("New signer created: ", signer.address);

    const message = code;

    // diff hash
    // var hash = "0x" + abi.soliditySHA3(
    //   ["address", "uint256"],
    //   [add1.address, 1]
    // ).toString("hex");

    // we hash the message 
    let hashedMessage = ethers.utils.id(message);
    console.log("hashedMessage is: ", hashedMessage);

    // we turn it into byte array
    let messageBytes = ethers.utils.arrayify(hashedMessage);
    console.log("messageBytes", messageBytes);

    // we sign this byte array with the private key
    let signature = await signer.signMessage(messageBytes);
    console.log("Final signature: ", signature);

    console.log("balance relic: ", await relic.balanceOf(add1.address));

    await network.provider.send("evm_increaseTime", [8640000]);
    await network.provider.send("evm_mine"); // this one 

    // SACRIFICE
    // console.log("PRICE TEST: ", await templeWL.test());
    
    await dummycoin.connect(add1).approve(templeWL.address, "1000000000000000000000");
    await templeWL.connect(add1).sacrifice();
    await relic.connect(add1).mintRelic(0);
    console.log("balance relic: ", await relic.balanceOf(add1.address));

    // mint shard
    
    await partnerMinter.mintShard(0,add1.address);
    await partnerMinter.mintShard(1,add1.address);
    console.log("balance0: ", await shards.balanceOf(add1.address, 0));


    // equip 
    // await shards.connect(add1).setApprovalForAll(shards.address,true);
    await relic.connect(add1).batchEquipShard(0, [0],[1]);

    console.log("balance0: ", await shards.balanceOf(add1.address, 0));
    console.log("balance1: ", await shards.balanceOf(add1.address, 1));
    console.log("balance2: ", await shards.balanceOf(add1.address, 2));

    // await shards.connect(add1).transmute(0);

    console.log("balance0: ", await shards.balanceOf(add1.address, 0));
    console.log("balance1: ", await shards.balanceOf(add1.address, 1));
    console.log("balance2: ", await shards.balanceOf(add1.address, 2));
  });

  xit("Should test erc20 contract outbound", async ()=>{
    await dummycoin.connect(add1).getmooni();
    // await dummycoin.connect(add1).transfer(test.address,ethers.utils.parseUnits("1000", 18));
    console.log("ADD4 eth balance: ",await ethers.provider.getBalance(add4.address));
    console.log("ADD2 erc20 balance: ", await dummycoin.balanceOf(add2.address));

    // setup
    await test.editDeployer(add4.address);
    await test.editSplits([add1.address, add2.address,add3.address,add4.address, add5.address,add6.address,add7.address, add8.address,add9.address],[200,180,180,180,45,45,45,17,13]);

    // await dummycoin.connect(add1).increaseAllowance(test.address,ethers.utils.parseEther("10000"));
    // await test.connect(add1).splitOther(dummycoin.address);
    console.log("ADD2 erc20 balance: ",await dummycoin.balanceOf(add2.address));
    console.log("ADD3 erc20 balance: ",await dummycoin.balanceOf(add3.address));

    console.log("///////////////////////");
    console.log("ADD1 eth balance: ",await ethers.provider.getBalance(add1.address));

    // eth
    // await test.connect(add1).tester({
    //   value: ethers.utils.parseEther("10") 
    // });
    console.log("ADD2 eth balance: ", await ethers.provider.getBalance(add2.address));
    console.log("ADD3 eth balance: ",await ethers.provider.getBalance(add3.address));


    await test.connect(add1).splitEth({
      value: ethers.utils.parseEther("10") 
    });;
    console.log("ADD1 eth balance: ",await ethers.provider.getBalance(add1.address));
    console.log("ADD2 eth balance: ",await ethers.provider.getBalance(add2.address));
    console.log("ADD3 eth balance: ",await ethers.provider.getBalance(add3.address));
    console.log("ADD4 eth balance: ",await ethers.provider.getBalance(add4.address));

  });
  
});
