const deploy = async () => {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Raffle = await ethers.getContractFactory("Raffle");
  // TODO: Change date
  const revealDate = Date.now() / 1000; // Test only
  const deployed = await Raffle.deploy(10000, revealDate.toFixed(0));

  console.log("Raffle NFT address:", deployed.address);
};

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
