// Ethereum & BSC wallets using Ethers.js
const connectWalletBtn = document.getElementById("connectWalletBtn");
const buyBtn = document.getElementById("buyBtn");
const buyAmountInput = document.getElementById("buyAmount");

let provider;
let signer;
let userAddress;

async function connectWallet() {
    if (window.ethereum) {
        try {
            await window.ethereum.request({ method: "eth_requestAccounts" });
            provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            userAddress = await signer.getAddress();
            connectWalletBtn.innerText = `Connected: ${userAddress.slice(0,6)}...${userAddress.slice(-4)}`;
        } catch (error) {
            console.error(error);
        }
    } else {
        alert("Please install MetaMask or a compatible wallet!");
    }
}

async function buyDRC() {
    const amount = buyAmountInput.value;
    if (!amount || amount <= 0) {
        alert("Enter a valid amount!");
        return;
    }

    const contractAddress = "YOUR_DRC_CONTRACT_ADDRESS";
    const abi = [ 
        "function buy() public payable"
    ];
    const contract = new ethers.Contract(contractAddress, abi, signer);

    try {
        const tx = await contract.buy({ value: ethers.utils.parseEther(amount) });
        await tx.wait();
        alert("DRC purchased successfully!");
    } catch (err) {
        console.error(err);
        alert("Transaction failed!");
    }
}

connectWalletBtn.addEventListener("click", connectWallet);
buyBtn.addEventListener("click", buyDRC);
