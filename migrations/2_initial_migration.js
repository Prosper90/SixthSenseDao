const SSDNFT = artifacts.require("SSDNFT");

module.exports = async function (deployer) {

  await deployer.deploy(SSDNFT, "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56");

  const saleInstance = await SSDNFT.deployed();

  console.log("NFTMint deployed at:", saleInstance.address);
};