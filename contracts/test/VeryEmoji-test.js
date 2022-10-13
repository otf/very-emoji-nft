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

    it("Should mint a token with token ID 0 & 1 to account1", async function () {
      const address1=account1.address;
      await token721.connect(account1).mint(0);
      expect(await token721.ownerOf(0)).to.equal(address1);

      await token721.connect(account1).mint(1);
      expect(await token721.ownerOf(1)).to.equal(address1);

      expect(await token721.balanceOf(address1)).to.equal(2);      
    });

    it("Should have a tokenURI", async function () {
      expect(await token721.tokenURI(0)).to.equal("ipfs://QmSxvj2y3ktM8EErNvzfBiUBFDBNRW4GBTomGpvrfM25Td/0");
      expect(await token721.tokenURI(1)).to.equal("ipfs://QmSxvj2y3ktM8EErNvzfBiUBFDBNRW4GBTomGpvrfM25Td/1");
    });

    it("Should be able to mint until the maxSupply", async function () {
      const address1 = account1.address;
      const maxSupply = await token721.maxSupply();

      for (i = 0; i < maxSupply; i++) {
        await token721.connect(account1).mint(i);
      }

      expect(await token721.balanceOf(address1)).to.equal(maxSupply);
    });

    it("Should be reject minting more than the maxSupply", async function () {
      const address1 = account1.address;
      const maxSupply = await token721.maxSupply();

      for (i = 0; i < maxSupply; i++) {
        await token721.connect(account1).mint(i);
      }

      await expect(token721.connect(account1).mint(maxSupply)).to.be.reverted;
    });

    it("Should has no totalSupply just after the contract created.", async function () {
      expect(await token721.totalSupply()).to.equal(0);
    });

    it("Should be able to get totalSupply", async function () {
      const address1 = account1.address;
      const mintAmount = 3;

      for (i = 0; i < mintAmount; i++) {
        await token721.connect(account1).mint(i);
      }

      expect(await token721.totalSupply()).to.equal(mintAmount);
    });

    it("Should has mintedTokenIds is empty while no minting.", async function () {
      const address1 = account1.address;

      expect(await token721.mintedTokenIds()).to.eql([]);
    });

    it("Should has mintedTokenIds is [0] after minting #0.", async function () {
      const address1 = account1.address;
      await token721.connect(account1).mint(0);

      expect(await token721.mintedTokenIds()).to.eql([ethers.BigNumber.from(0)]);
    });

    it("Should has mintedTokenIds is [0, 2] after minting #0 and #2.", async function () {
      const address1 = account1.address;
      await token721.connect(account1).mint(0);
      await token721.connect(account1).mint(2);

      expect(await token721.mintedTokenIds()).to.eql([ethers.BigNumber.from(0),ethers.BigNumber.from(2)]);
    });

    it("Should has mintedTokenIds is [0..(maxSupply-1)] after minting all.", async function () {
      const address1 = account1.address;
      const maxSupply = await token721.maxSupply();

      for (i = 0; i < maxSupply; i++) {
        await token721.connect(account1).mint(i);
      }

      expect(await token721.mintedTokenIds()).to.eql([...Array(Number(maxSupply)).keys()].map(ethers.BigNumber.from));
    });
  });
});
