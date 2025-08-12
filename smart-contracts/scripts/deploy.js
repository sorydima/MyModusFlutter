async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const Escrow = await ethers.getContractFactory('Escrow');
  const escrow = await Escrow.deploy();
  await escrow.deployed();
  console.log('Escrow deployed to:', escrow.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
