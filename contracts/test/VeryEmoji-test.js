// test/VeryEmoji-test.js
const { expect } = require("chai");

describe("VeryEmoji contract", function () {
  let VeryEmoji;
  let token721;
  let account1,otheraccounts;

  beforeEach(async function () {
    VeryEmoji = await ethers.getContractFactory("VeryEmoji");
   [owner, account1, ...otheraccounts] = await ethers.getSigners();

    token721 = await VeryEmoji.deploy();
  });

  // You can nest describe calls to create subsections.
  describe("Deployment", function () {

    it("Should has the correct name and symbol ", async function () {
      expect(await token721.name()).to.equal("VeryEmoji");
      expect(await token721.symbol()).to.equal("EMOJI");
    });

    it("Should mint a token with token ID 1 & 2 to account1", async function () {
      const address1=account1.address;
      await token721.mint(address1, 1);
      expect(await token721.ownerOf(1)).to.equal(address1);

      await token721.mint(address1, 2);
      expect(await token721.ownerOf(2)).to.equal(address1);

      expect(await token721.balanceOf(address1)).to.equal(2);      
    });

    it("Should have a tokenURI", async function () {
      expect(await token721.tokenURI(1)).to.equal("ipfs://QmarZTMidah5GKmDHrH8V4w5XBh6goid1YMqpo6XTrgVPy/1.json");
      expect(await token721.tokenURI(2)).to.equal("ipfs://QmarZTMidah5GKmDHrH8V4w5XBh6goid1YMqpo6XTrgVPy/2.json");
    });

  });
});
