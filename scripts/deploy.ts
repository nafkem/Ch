import { ethers } from "hardhat";

async function main() {
  // const Token = await ethers.getContractFactory("CVIII");
  // const token = await Token.deploy("web3Bridge", "VIII");
  // await token.deployed();
  const MyERC721 = await ethers.deployContract("MyERC721",["NAFK","NAF","QmXgLtjVRLaoXcoJ1b2mgzddLGyPdPTGChshUWBcMvMk45"]); 
  await MyERC721.waitForDeployment();
  
  console.log(
    `MyERC721 contract deployed to ${MyERC721.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
