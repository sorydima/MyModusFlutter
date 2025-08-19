const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyModusNFT", function () {
  let MyModusNFT;
  let nftContract;
  let owner;
  let user1;
  let user2;
  let addrs;

  beforeEach(async function () {
    // Получаем аккаунты
    [owner, user1, user2, ...addrs] = await ethers.getSigners();

    // Деплоим контракт
    MyModusNFT = await ethers.getContractFactory("MyModusNFT");
    nftContract = await MyModusNFT.deploy();
    await nftContract.waitForDeployment();
  });

  describe("Деплой", function () {
    it("Должен корректно развернуть контракт", async function () {
      expect(await nftContract.name()).to.equal("MyModus NFT");
      expect(await nftContract.symbol()).to.equal("MMNFT");
      expect(await nftContract.owner()).to.equal(owner.address);
    });

    it("Должен установить правильного владельца", async function () {
      expect(await nftContract.owner()).to.equal(owner.address);
    });
  });

  describe("Минтинг NFT", function () {
    const tokenURI = "ipfs://QmTestNFTMetadata";
    const name = "Test NFT";
    const description = "Test NFT description";
    const imageURI = "ipfs://QmTestImage";
    const category = "Test";

    it("Должен позволить владельцу минтить NFT", async function () {
      const mintTx = await nftContract.mintNFT(
        user1.address,
        tokenURI,
        name,
        description,
        imageURI,
        category
      );

      await expect(mintTx)
        .to.emit(nftContract, "NFTMinted")
        .withArgs(1, owner.address, tokenURI);

      expect(await nftContract.ownerOf(1)).to.equal(user1.address);
      expect(await nftContract.tokenURI(1)).to.equal(tokenURI);
    });

    it("Должен сохранить метаданные NFT", async function () {
      await nftContract.mintNFT(
        user1.address,
        tokenURI,
        name,
        description,
        imageURI,
        category
      );

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.name).to.equal(name);
      expect(metadata.description).to.equal(description);
      expect(metadata.imageURI).to.equal(imageURI);
      expect(metadata.category).to.equal(category);
      expect(metadata.creator).to.equal(owner.address);
      expect(metadata.isForSale).to.equal(false);
      expect(metadata.price).to.equal(0);
    });

    it("Должен увеличить счетчик токенов", async function () {
      await nftContract.mintNFT(
        user1.address,
        tokenURI,
        name,
        description,
        imageURI,
        category
      );

      expect(await nftContract.totalSupply()).to.equal(1);
    });

    it("Должен обновить счетчик создателя", async function () {
      await nftContract.mintNFT(
        user1.address,
        tokenURI,
        name,
        description,
        imageURI,
        category
      );

      expect(await nftContract.creatorNFTCount(owner.address)).to.equal(1);
    });

    it("Не должен позволить минтить с пустым названием", async function () {
      await expect(
        nftContract.mintNFT(
          user1.address,
          tokenURI,
          "",
          description,
          imageURI,
          category
        )
      ).to.be.revertedWith("Name cannot be empty");
    });

    it("Не должен позволить минтить с пустым описанием", async function () {
      await expect(
        nftContract.mintNFT(
          user1.address,
          tokenURI,
          name,
          "",
          imageURI,
          category
        )
      ).to.be.revertedWith("Description cannot be empty");
    });

    it("Не должен позволить минтить с пустым URI изображения", async function () {
      await expect(
        nftContract.mintNFT(
          user1.address,
          tokenURI,
          name,
          description,
          "",
          category
        )
      ).to.be.revertedWith("Image URI cannot be empty");
    });
  });

  describe("Управление метаданными", function () {
    beforeEach(async function () {
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest",
        "Original Name",
        "Original Description",
        "ipfs://QmImage",
        "Original Category"
      );
    });

    it("Должен позволить владельцу обновлять метаданные", async function () {
      const newName = "Updated Name";
      const newDescription = "Updated Description";

      await expect(
        nftContract.connect(user1).updateMetadata(1, newName, newDescription)
      )
        .to.emit(nftContract, "NFTMetadataUpdated")
        .withArgs(1, newName, newDescription);

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.name).to.equal(newName);
      expect(metadata.description).to.equal(newDescription);
    });

    it("Не должен позволить не владельцу обновлять метаданные", async function () {
      await expect(
        nftContract.connect(user2).updateMetadata(1, "New Name", "New Description")
      ).to.be.revertedWith("Not token owner");
    });

    it("Не должен позволить обновлять с пустым названием", async function () {
      await expect(
        nftContract.connect(user1).updateMetadata(1, "", "New Description")
      ).to.be.revertedWith("Name cannot be empty");
    });

    it("Не должен позволить обновлять с пустым описанием", async function () {
      await expect(
        nftContract.connect(user1).updateMetadata(1, "New Name", "")
      ).to.be.revertedWith("Description cannot be empty");
    });
  });

  describe("Продажа NFT", function () {
    beforeEach(async function () {
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest",
        "Test NFT",
        "Test Description",
        "ipfs://QmImage",
        "Test Category"
      );
    });

    it("Должен позволить владельцу выставить NFT на продажу", async function () {
      const price = ethers.parseEther("0.1");

      await expect(
        nftContract.connect(user1).putForSale(1, price)
      )
        .to.emit(nftContract, "NFTPutForSale")
        .withArgs(1, price);

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.isForSale).to.equal(true);
      expect(metadata.price).to.equal(price);
    });

    it("Не должен позволить не владельцу выставлять на продажу", async function () {
      await expect(
        nftContract.connect(user2).putForSale(1, ethers.parseEther("0.1"))
      ).to.be.revertedWith("Not token owner");
    });

    it("Не должен позволить выставлять с нулевой ценой", async function () {
      await expect(
        nftContract.connect(user1).putForSale(1, 0)
      ).to.be.revertedWith("Price must be greater than 0");
    });

    it("Должен позволить владельцу убрать с продажи", async function () {
      await nftContract.connect(user1).putForSale(1, ethers.parseEther("0.1"));

      await expect(
        nftContract.connect(user1).removeFromSale(1)
      )
        .to.emit(nftContract, "NFTRemovedFromSale")
        .withArgs(1);

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.isForSale).to.equal(false);
      expect(metadata.price).to.equal(0);
    });

    it("Должен позволить владельцу обновить цену", async function () {
      await nftContract.connect(user1).putForSale(1, ethers.parseEther("0.1"));

      const newPrice = ethers.parseEther("0.2");

      await expect(
        nftContract.connect(user1).updatePrice(1, newPrice)
      )
        .to.emit(nftContract, "NFTPriceUpdated")
        .withArgs(1, newPrice);

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.price).to.equal(newPrice);
    });
  });

  describe("Покупка NFT", function () {
    beforeEach(async function () {
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest",
        "Test NFT",
        "Test Description",
        "ipfs://QmImage",
        "Test Category"
      );
      await nftContract.connect(user1).putForSale(1, ethers.parseEther("0.1"));
    });

    it("Должен позволить покупать NFT", async function () {
      const price = ethers.parseEther("0.1");
      const initialBalance = await ethers.provider.getBalance(user1.address);

      await nftContract.connect(user2).buyNFT(1, { value: price });

      expect(await nftContract.ownerOf(1)).to.equal(user2.address);

      const metadata = await nftContract.getNFTMetadata(1);
      expect(metadata.isForSale).to.equal(false);
      expect(metadata.price).to.equal(0);
    });

    it("Не должен позволить покупать собственный NFT", async function () {
      await expect(
        nftContract.connect(user1).buyNFT(1, { value: ethers.parseEther("0.1") })
      ).to.be.revertedWith("Cannot buy your own token");
    });

    it("Не должен позволить покупать с недостаточной оплатой", async function () {
      await expect(
        nftContract.connect(user2).buyNFT(1, { value: ethers.parseEther("0.05") })
      ).to.be.revertedWith("Insufficient payment");
    });

    it("Должен возвращать излишки", async function () {
      const price = ethers.parseEther("0.1");
      const overpayment = ethers.parseEther("0.05");
      const totalPayment = price + overpayment;

      const initialBalance = await ethers.provider.getBalance(user2.address);

      await nftContract.connect(user2).buyNFT(1, { value: totalPayment });

      const finalBalance = await ethers.provider.getBalance(user2.address);
      expect(finalBalance).to.be.closeTo(
        initialBalance - price,
        ethers.parseEther("0.001") // Погрешность на газ
      );
    });
  });

  describe("Получение данных", function () {
    beforeEach(async function () {
      // Минтим несколько NFT
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest1",
        "NFT 1",
        "Description 1",
        "ipfs://QmImage1",
        "Category 1"
      );
      await nftContract.mintNFT(
        user2.address,
        "ipfs://QmTest2",
        "NFT 2",
        "Description 2",
        "ipfs://QmImage2",
        "Category 2"
      );
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest3",
        "NFT 3",
        "Description 3",
        "ipfs://QmImage3",
        "Category 3"
      );
    });

    it("Должен возвращать NFT пользователя", async function () {
      const user1NFTs = await nftContract.getUserNFTs(user1.address);
      expect(user1NFTs.length).to.equal(2);
      expect(user1NFTs[0]).to.equal(1);
      expect(user1NFTs[2]).to.equal(3);
    });

    it("Должен возвращать NFT на продаже", async function () {
      await nftContract.connect(user1).putForSale(1, ethers.parseEther("0.1"));
      await nftContract.connect(user2).putForSale(2, ethers.parseEther("0.2"));

      const forSaleNFTs = await nftContract.getNFTsForSale();
      expect(forSaleNFTs.length).to.equal(2);
    });

    it("Должен возвращать статистику", async function () {
      const stats = await nftContract.getStats();
      expect(stats.totalNFTs).to.equal(3);
      expect(stats.totalCreators).to.equal(2); // owner и user2
      expect(stats.nftsForSale).to.equal(0);
    });
  });

  describe("Сжигание NFT", function () {
    beforeEach(async function () {
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest",
        "Test NFT",
        "Test Description",
        "ipfs://QmImage",
        "Test Category"
      );
    });

    it("Должен позволить владельцу сжигать NFT", async function () {
      await nftContract.connect(user1).burn(1);

      await expect(nftContract.ownerOf(1)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Должен очищать метаданные при сжигании", async function () {
      await nftContract.connect(user1).burn(1);

      // Попытка получить метаданные сожженного токена должна вызвать ошибку
      await expect(nftContract.getNFTMetadata(1)).to.be.revertedWith("Token does not exist");
    });

    it("Должен обновлять счетчик создателя при сжигании", async function () {
      const initialCount = await nftContract.creatorNFTCount(owner.address);
      await nftContract.connect(user1).burn(1);

      // Счетчик должен уменьшиться
      expect(await nftContract.creatorNFTCount(owner.address)).to.equal(initialCount - 1);
    });
  });

  describe("Безопасность", function () {
    it("Не должен позволить минтить несуществующему адресу", async function () {
      await expect(
        nftContract.mintNFT(
          ethers.ZeroAddress,
          "ipfs://QmTest",
          "Test NFT",
          "Test Description",
          "ipfs://QmImage",
          "Test Category"
        )
      ).to.be.revertedWith("ERC721: mint to the zero address");
    });

    it("Должен корректно обрабатывать передачу токенов", async function () {
      await nftContract.mintNFT(
        user1.address,
        "ipfs://QmTest",
        "Test NFT",
        "Test Description",
        "ipfs://QmImage",
        "Test Category"
      );

      await nftContract.connect(user1).transferFrom(user1.address, user2.address, 1);
      expect(await nftContract.ownerOf(1)).to.equal(user2.address);
    });
  });
});
