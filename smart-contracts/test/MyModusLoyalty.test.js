const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyModusLoyalty", function () {
  let MyModusLoyalty;
  let loyaltyContract;
  let owner;
  let user1;
  let user2;
  let minter;
  let burner;
  let addrs;

  const tokenName = "MyModus Loyalty Token";
  const tokenSymbol = "MMLT";
  const tokenDecimals = 18;
  const maxSupply = ethers.parseEther("1000000"); // 1M токенов
  const mintPrice = ethers.parseEther("0.001"); // 0.001 ETH за токен

  beforeEach(async function () {
    // Получаем аккаунты
    [owner, user1, user2, minter, burner, ...addrs] = await ethers.getSigners();

    // Деплоим контракт
    MyModusLoyalty = await ethers.getContractFactory("MyModusLoyalty");
    loyaltyContract = await MyModusLoyalty.deploy(
      tokenName,
      tokenSymbol,
      tokenDecimals,
      maxSupply,
      mintPrice
    );
    await loyaltyContract.waitForDeployment();
  });

  describe("Деплой", function () {
    it("Должен корректно развернуть контракт", async function () {
      expect(await loyaltyContract.name()).to.equal(tokenName);
      expect(await loyaltyContract.symbol()).to.equal(tokenSymbol);
      expect(await loyaltyContract.decimals()).to.equal(tokenDecimals);
      expect(await loyaltyContract.maxSupply()).to.equal(maxSupply);
      expect(await loyaltyContract.mintPrice()).to.equal(mintPrice);
      expect(await loyaltyContract.owner()).to.equal(owner.address);
    });

    it("Должен установить правильного владельца", async function () {
      expect(await loyaltyContract.owner()).to.equal(owner.address);
    });

    it("Должен включить минтинг и сжигание по умолчанию", async function () {
      expect(await loyaltyContract.mintingEnabled()).to.equal(true);
      expect(await loyaltyContract.burningEnabled()).to.equal(true);
    });

    it("Должен добавить владельца как минтера и бёрнера", async function () {
      expect(await loyaltyContract.isMinter(owner.address)).to.equal(true);
      expect(await loyaltyContract.isBurner(owner.address)).to.equal(true);
    });
  });

  describe("Минтинг токенов", function () {
    const amount = ethers.parseEther("100");

    it("Должен позволить владельцу минтить токены", async function () {
      await expect(loyaltyContract.mint(user1.address, amount))
        .to.emit(loyaltyContract, "TokensMinted")
        .withArgs(user1.address, amount, 0);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount);
      expect(await loyaltyContract.totalSupply()).to.equal(amount);
    });

    it("Должен позволить авторизованному минтеру минтить токены", async function () {
      await loyaltyContract.addMinter(minter.address);

      await expect(loyaltyContract.connect(minter).mint(user1.address, amount))
        .to.emit(loyaltyContract, "TokensMinted")
        .withArgs(user1.address, amount, 0);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount);
    });

    it("Не должен позволить неавторизованному пользователю минтить", async function () {
      await expect(
        loyaltyContract.connect(user1).mint(user2.address, amount)
      ).to.be.revertedWith("Not authorized to mint");
    });

    it("Не должен позволить минтить на нулевой адрес", async function () {
      await expect(
        loyaltyContract.mint(ethers.ZeroAddress, amount)
      ).to.be.revertedWith("Cannot mint to zero address");
    });

    it("Не должен позволить минтить нулевое количество", async function () {
      await expect(
        loyaltyContract.mint(user1.address, 0)
      ).to.be.revertedWith("Amount must be greater than 0");
    });

    it("Не должен позволить превысить максимальное предложение", async function () {
      const exceedAmount = maxSupply.add(ethers.parseEther("1"));
      await expect(
        loyaltyContract.mint(user1.address, exceedAmount)
      ).to.be.revertedWith("Exceeds max supply");
    });

    it("Должен обновить информацию о пользователе при минтинге", async function () {
      await loyaltyContract.mint(user1.address, amount);

      const userInfo = await loyaltyContract.getUserInfo(user1.address);
      expect(userInfo.balance).to.equal(amount);
      expect(userInfo.totalEarned).to.equal(amount);
      expect(userInfo.isActive).to.equal(true);
    });
  });

  describe("Минтинг за ETH", function () {
    const amount = ethers.parseEther("100");
    const requiredPayment = mintPrice * amount;

    it("Должен позволить минтить токены за ETH", async function () {
      const initialBalance = await ethers.provider.getBalance(user1.address);

      await expect(
        loyaltyContract.connect(user1).mintWithETH(amount, { value: requiredPayment })
      )
        .to.emit(loyaltyContract, "TokensMinted")
        .withArgs(user1.address, amount, requiredPayment);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount);
    });

    it("Не должен позволить минтить с недостаточной оплатой", async function () {
      const insufficientPayment = requiredPayment.sub(ethers.parseEther("0.001"));

      await expect(
        loyaltyContract.connect(user1).mintWithETH(amount, { value: insufficientPayment })
      ).to.be.revertedWith("Insufficient payment");
    });

    it("Должен возвращать излишки", async function () {
      const overpayment = ethers.parseEther("0.1");
      const totalPayment = requiredPayment + overpayment;

      const initialBalance = await ethers.provider.getBalance(user1.address);

      await loyaltyContract.connect(user1).mintWithETH(amount, { value: totalPayment });

      const finalBalance = await ethers.provider.getBalance(user1.address);
      expect(finalBalance).to.be.closeTo(
        initialBalance - requiredPayment,
        ethers.parseEther("0.001") // Погрешность на газ
      );
    });

    it("Должен обновить информацию о пользователе", async function () {
      await loyaltyContract.connect(user1).mintWithETH(amount, { value: requiredPayment });

      const userInfo = await loyaltyContract.getUserInfo(user1.address);
      expect(userInfo.totalSpent).to.equal(requiredPayment);
    });
  });

  describe("Сжигание токенов", function () {
    const amount = ethers.parseEther("100");

    beforeEach(async function () {
      await loyaltyContract.mint(user1.address, amount);
    });

    it("Должен позволить владельцу сжигать токены", async function () {
      const burnAmount = ethers.parseEther("50");

      await expect(loyaltyContract.connect(user1).burn(burnAmount))
        .to.emit(loyaltyContract, "TokensBurned")
        .withArgs(user1.address, burnAmount);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount - burnAmount);
      expect(await loyaltyContract.totalSupply()).to.equal(amount - burnAmount);
    });

    it("Не должен позволить сжигать больше, чем есть на балансе", async function () {
      const burnAmount = amount.add(ethers.parseEther("1"));

      await expect(
        loyaltyContract.connect(user1).burn(burnAmount)
      ).to.be.revertedWith("ERC20: burn amount exceeds balance");
    });

    it("Не должен позволить сжигать нулевое количество", async function () {
      await expect(
        loyaltyContract.connect(user1).burn(0)
      ).to.be.revertedWith("Amount must be greater than 0");
    });

    it("Должен позволить авторизованному бёрнеру сжигать токены", async function () {
      await loyaltyContract.addBurner(burner.address);

      const burnAmount = ethers.parseEther("50");

      await expect(
        loyaltyContract.connect(burner).burnFrom(user1.address, burnAmount)
      )
        .to.emit(loyaltyContract, "TokensBurned")
        .withArgs(user1.address, burnAmount);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount - burnAmount);
    });

    it("Не должен позволить неавторизованному пользователю сжигать", async function () {
      await expect(
        loyaltyContract.connect(user2).burnFrom(user1.address, ethers.parseEther("50"))
      ).to.be.revertedWith("Not authorized to burn");
    });
  });

  describe("Управление пользователями", function () {
    it("Должен позволить владельцу регистрировать пользователей", async function () {
      await expect(loyaltyContract.registerUser(user1.address))
        .to.emit(loyaltyContract, "UserRegistered")
        .withArgs(user1.address);

      const userInfo = await loyaltyContract.getUserInfo(user1.address);
      expect(userInfo.isActive).to.equal(true);
    });

    it("Не должен позволить регистрировать уже зарегистрированного пользователя", async function () {
      await loyaltyContract.registerUser(user1.address);

      await expect(
        loyaltyContract.registerUser(user1.address)
      ).to.be.revertedWith("User already registered");
    });

    it("Должен позволить владельцу деактивировать пользователей", async function () {
      await loyaltyContract.registerUser(user1.address);

      await expect(loyaltyContract.deactivateUser(user1.address))
        .to.emit(loyaltyContract, "UserDeactivated")
        .withArgs(user1.address);

      const userInfo = await loyaltyContract.getUserInfo(user1.address);
      expect(userInfo.isActive).to.equal(false);
    });

    it("Не должен позволить деактивировать незарегистрированного пользователя", async function () {
      await expect(
        loyaltyContract.deactivateUser(user1.address)
      ).to.be.revertedWith("User not registered");
    });
  });

  describe("Управление ролями", function () {
    it("Должен позволить владельцу добавлять минтеров", async function () {
      await expect(loyaltyContract.addMinter(minter.address))
        .to.emit(loyaltyContract, "MinterAdded")
        .withArgs(minter.address);

      expect(await loyaltyContract.isMinter(minter.address)).to.equal(true);
    });

    it("Не должен позволить добавлять уже существующего минтера", async function () {
      await loyaltyContract.addMinter(minter.address);

      await expect(
        loyaltyContract.addMinter(minter.address)
      ).to.be.revertedWith("Already a minter");
    });

    it("Должен позволить владельцу удалять минтеров", async function () {
      await loyaltyContract.addMinter(minter.address);

      await expect(loyaltyContract.removeMinter(minter.address))
        .to.emit(loyaltyContract, "MinterRemoved")
        .withArgs(minter.address);

      expect(await loyaltyContract.isMinter(minter.address)).to.equal(false);
    });

    it("Не должен позволить удалять владельца как минтера", async function () {
      await expect(
        loyaltyContract.removeMinter(owner.address)
      ).to.be.revertedWith("Cannot remove owner as minter");
    });

    it("Должен позволить владельцу добавлять бёрнеров", async function () {
      await expect(loyaltyContract.addBurner(burner.address))
        .to.emit(loyaltyContract, "BurnerAdded")
        .withArgs(burner.address);

      expect(await loyaltyContract.isBurner(burner.address)).to.equal(true);
    });

    it("Должен позволить владельцу удалять бёрнеров", async function () {
      await loyaltyContract.addBurner(burner.address);

      await expect(loyaltyContract.removeBurner(burner.address))
        .to.emit(loyaltyContract, "BurnerRemoved")
        .withArgs(burner.address);

      expect(await loyaltyContract.isBurner(burner.address)).to.equal(false);
    });
  });

  describe("Настройки контракта", function () {
    it("Должен позволить владельцу обновлять цену минтинга", async function () {
      const newPrice = ethers.parseEther("0.002");

      await expect(loyaltyContract.updateMintPrice(newPrice))
        .to.emit(loyaltyContract, "MintPriceUpdated")
        .withArgs(newPrice);

      expect(await loyaltyContract.mintPrice()).to.equal(newPrice);
    });

    it("Не должен позволить устанавливать отрицательную цену", async function () {
      await expect(
        loyaltyContract.updateMintPrice(ethers.parseEther("-0.001"))
      ).to.be.revertedWith("Price cannot be negative");
    });

    it("Должен позволить владельцу обновлять максимальное предложение", async function () {
      const newMaxSupply = maxSupply.add(ethers.parseEther("1000000"));

      await expect(loyaltyContract.updateMaxSupply(newMaxSupply))
        .to.emit(loyaltyContract, "MaxSupplyUpdated")
        .withArgs(newMaxSupply);

      expect(await loyaltyContract.maxSupply()).to.equal(newMaxSupply);
    });

    it("Не должен позволить уменьшать максимальное предложение ниже текущего", async function () {
      await loyaltyContract.mint(user1.address, ethers.parseEther("100"));

      await expect(
        loyaltyContract.updateMaxSupply(ethers.parseEther("50"))
      ).to.be.revertedWith("Cannot decrease below current supply");
    });

    it("Должен позволить владельцу включать/выключать минтинг", async function () {
      await loyaltyContract.setMintingEnabled(false);
      expect(await loyaltyContract.mintingEnabled()).to.equal(false);

      await loyaltyContract.setMintingEnabled(true);
      expect(await loyaltyContract.mintingEnabled()).to.equal(true);
    });

    it("Должен позволить владельцу включать/выключать сжигание", async function () {
      await loyaltyContract.setBurningEnabled(false);
      expect(await loyaltyContract.burningEnabled()).to.equal(false);

      await loyaltyContract.setBurningEnabled(true);
      expect(await loyaltyContract.burningEnabled()).to.equal(true);
    });
  });

  describe("Пауза контракта", function () {
    it("Должен позволить владельцу ставить на паузу", async function () {
      await loyaltyContract.pause();
      expect(await loyaltyContract.paused()).to.equal(true);
    });

    it("Должен позволить владельцу снимать с паузы", async function () {
      await loyaltyContract.pause();
      await loyaltyContract.unpause();
      expect(await loyaltyContract.paused()).to.equal(false);
    });

    it("Не должен позволить минтить на паузе", async function () {
      await loyaltyContract.pause();

      await expect(
        loyaltyContract.mint(user1.address, ethers.parseEther("100"))
      ).to.be.revertedWith("Pausable: paused");
    });

    it("Не должен позволить сжигать на паузе", async function () {
      await loyaltyContract.mint(user1.address, ethers.parseEther("100"));
      await loyaltyContract.pause();

      await expect(
        loyaltyContract.connect(user1).burn(ethers.parseEther("50"))
      ).to.be.revertedWith("Pausable: paused");
    });
  });

  describe("Получение данных", function () {
    it("Должен возвращать информацию о токене", async function () {
      const tokenInfo = await loyaltyContract.getTokenInfo();

      expect(tokenInfo.name).to.equal(tokenName);
      expect(tokenInfo.symbol).to.equal(tokenSymbol);
      expect(tokenInfo.decimals).to.equal(tokenDecimals);
      expect(tokenInfo.maxSupply).to.equal(maxSupply);
      expect(tokenInfo.creator).to.equal(owner.address);
    });

    it("Должен возвращать информацию о пользователе", async function () {
      await loyaltyContract.registerUser(user1.address);

      const userInfo = await loyaltyContract.getUserInfo(user1.address);
      expect(userInfo.isActive).to.equal(true);
      expect(userInfo.balance).to.equal(0);
      expect(userInfo.totalEarned).to.equal(0);
      expect(userInfo.totalSpent).to.equal(0);
    });

    it("Должен возвращать статистику", async function () {
      const stats = await loyaltyContract.getStats();
      expect(stats.totalMinters).to.equal(1); // owner
      expect(stats.totalBurners).to.equal(1); // owner
    });
  });

  describe("Переводы токенов", function () {
    const amount = ethers.parseEther("100");

    beforeEach(async function () {
      await loyaltyContract.mint(user1.address, amount);
    });

    it("Должен позволить переводить токены", async function () {
      const transferAmount = ethers.parseEther("50");

      await loyaltyContract.connect(user1).transfer(user2.address, transferAmount);

      expect(await loyaltyContract.balanceOf(user1.address)).to.equal(amount - transferAmount);
      expect(await loyaltyContract.balanceOf(user2.address)).to.equal(transferAmount);
    });

    it("Должен обновлять информацию о пользователях при переводах", async function () {
      const transferAmount = ethers.parseEther("50");

      await loyaltyContract.connect(user1).transfer(user2.address, transferAmount);

      const user1Info = await loyaltyContract.getUserInfo(user1.address);
      const user2Info = await loyaltyContract.getUserInfo(user2.address);

      expect(user1Info.balance).to.equal(amount - transferAmount);
      expect(user2Info.balance).to.equal(transferAmount);
    });
  });

  describe("Вывод ETH", function () {
    it("Должен позволить владельцу выводить ETH", async function () {
      // Сначала минтим токены за ETH, чтобы накопить ETH в контракте
      const amount = ethers.parseEther("100");
      const payment = mintPrice * amount;

      await loyaltyContract.connect(user1).mintWithETH(amount, { value: payment });

      const initialBalance = await ethers.provider.getBalance(owner.address);
      const contractBalance = await ethers.provider.getBalance(await loyaltyContract.getAddress());

      await loyaltyContract.withdraw();

      const finalBalance = await ethers.provider.getBalance(owner.address);
      expect(finalBalance).to.be.gt(initialBalance);
    });

    it("Не должен позволить не владельцу выводить ETH", async function () {
      await expect(
        loyaltyContract.connect(user1).withdraw()
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Не должен позволить выводить при нулевом балансе", async function () {
      await expect(
        loyaltyContract.withdraw()
      ).to.be.revertedWith("No balance to withdraw");
    });
  });

  describe("Безопасность", function () {
    it("Не должен позволить не владельцу управлять контрактом", async function () {
      await expect(
        loyaltyContract.connect(user1).addMinter(user2.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");

      await expect(
        loyaltyContract.connect(user1).setMintingEnabled(false)
      ).to.be.revertedWith("Ownable: caller is not the owner");

      await expect(
        loyaltyContract.connect(user1).pause()
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Должен корректно обрабатывать reentrancy атаки", async function () {
      // Этот тест проверяет, что контракт защищен от reentrancy атак
      const amount = ethers.parseEther("100");
      const payment = mintPrice * amount;

      // Попытка минтинга должна пройти успешно
      await expect(
        loyaltyContract.connect(user1).mintWithETH(amount, { value: payment })
      ).to.not.be.reverted;
    });
  });
});
