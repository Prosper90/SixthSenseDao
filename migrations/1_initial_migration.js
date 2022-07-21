const NFTMint = artifacts.require("SSDNFTMint");

module.exports = async function (deployer) {

  await deployer.deploy(NFTMint, "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56");

  const saleInstance = await NFTMint.deployed();

  console.log("NFTMint deployed at:", saleInstance.address);
};
