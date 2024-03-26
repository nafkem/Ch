// import { ethers } from 'hardhat';
// import { TokenSwap } from "../typechain-types";
// import TokenSwapABI from '../artifacts/contracts/TokenSwap.sol/TokenSwap.json';
// import Token1ABI from '../artifacts/contracts/Token1.sol/Token1.json';
// import Token2ABI from '../artifacts/contracts/Token1.sol/Token1.json';

// async function main() {
//   const contractAddress = '0xa18c7A0206C9a8b39Ff6ae790044165363dF4081';
//   const Token1Address  = "0x6C89B04dB8A07903A5cF9A69Dc33faBf159A31EE";
//   const Token2Address  = "0xAf67D292D5df02AD57E603Cfc47430eEfe91A77f";

//   //const [deployer] = await ethers.getSigners();
//   const [owner] = await ethers.getSigners();

//   // Import the ABI
//   const tokenSwapABI = TokenSwapABI.abi;

//   // Connect to the deployed contract using the ABI
//   const Token1 = await ethers.getContractAt("Token1",contractAddress);
//   const Token2 = await ethers.getContractAt("Token2",contractAddress);
//   const SwapToken = await ethers.getContractAt("TokenSwap",contractAddress);

//   // Interact with the contract here

//   await Token1.approve(contractAddress, "100000000");
//   await SwapToken.setExchangeRate(Token1, Token2, "3000000000", "500000000");

//   console.log(' Staked tokens successfully.');

//   // Add more interactions as needed
// }

// main().then(() => process.exit(0)).catch(error => {
//   console.error(error);
//   process.exit(1);
// });