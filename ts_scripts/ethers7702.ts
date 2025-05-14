import { ethers } from 'ethers';
import * as dotenv from "dotenv";
dotenv.config();

const provider = new ethers.JsonRpcProvider(
    process.env.MAINNET_RPC_URL!
);
const privateKey = process.env.PK_1!;
const pk2 = process.env.PK_2!;
const signer_owner = new ethers.Wallet(privateKey, provider) as ethers.Signer;
const signer = new ethers.Wallet(pk2, provider);
const delegatedTo = '0x1Ec51ea2582B3B49967fc7b7036dC21Ac0a6Bc54'; // Smart EOA deployment

async function sendBasicTransaction() {
    const nonce = await provider.getTransactionCount(signer_owner.getAddress())
    const auth = await signer_owner.authorize({
        // address: delegatedTo,
        address: ethers.ZeroAddress, // Notice How to remove delegate call for EOA
        nonce: nonce,
        chainId: 1
    });
    const tx = {
        type: 4,
        to: "0x000000000000000000000000000000000000dEaD",
        value: ethers.parseUnits("0.0", "ether"),
        gasLimit: 80000,
        maxPriorityFeePerGas: ethers.parseUnits("2", "gwei"),
        maxFeePerGas: ethers.parseUnits("20", "gwei"),
        authorizationList: [auth] 
    };
  
    const txResponse = await signer.sendTransaction(tx);
    console.log("📤 Sent transaction:", txResponse.hash);
  
    const receipt = await txResponse.wait();
    console.log("✅ Mined in block:", receipt!.blockNumber);
  }
  
  sendBasicTransaction().catch(console.error);