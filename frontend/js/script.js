// Include Ethers.js in HTML <script src="https://cdn.jsdelivr.net/npm/ethers/dist/ethers.min.js"></script>
// Include Web3Modal in HTML as shown in previous index.html

let provider;
let signer;
let userAddress;
let drcContract;

// Your DRC contract info
const contractAddress = "YOUR_DRC_CONTRACT_ADDRESS";
const contractABI = [
    "function buy() public payable",
    "function balanceOf(address account) external view returns (uint256)"
];

// Elements
const connectWalletBtn = document.getElementById("connectWalletBtn");
const buyBtn = document.getElementById("buyBtn");
const buyAmountInput = document.getElementById("buyAmount");

// Web3Modal setup
const web3Modal = new window.Web3Modal.default({
    cacheProvider: true,
    providerOptions: {
        walletconnect: {
            package: window.WalletConnectProvider.default,
            options: {
                infuraId: "INFURA_PROJECT_ID" // optional for Ethereum & BSC
            }
        },
        coinbasewallet: {
            package: window.CoinbaseWalletSDK,
            options: {
                appName: "Daily Remit Coin DRC",
                infuraId: "INFURA_PROJECT_ID"
            }
        }
    }
});

// Connect Wallet
async function connectWallet() {
    try {
        const instance = await web3Modal.connect();
        provider = new ethers.providers.Web3Provider(instance);
        signer = provider.getSigner();
        userAddress = await signer.getAddress();
        connectWalletBtn.innerText = `Connected: ${userAddress.slice(0,6)}...${userAddress.slice(-4)}`;
        drcContract = new ethers.Contract(contractAddress, contractABI, signer);
        await displayBalance();
    } catch (err) {
        console.error(err);
        alert("Wallet connection failed!");
    }
}

// Display DRC Balance
async function displayBalance() {
    if (!drcContract || !userAddress) return;
    try {
        const balance = await drcContract.balanceOf(userAddress);
        const formatted = ethers.utils.formatUnits(balance, 18);
        connectWalletBtn.innerText = `Balance: ${formatted} DRC`;
    } catch (err) {
        console.error("Failed to fetch balance:", err);
    }
}

// Buy DRC
async function buyDRC() {
    const amount = buyAmountInput.value;
    if (!amount || amount <= 0) {
        alert("Enter a valid amount!");
        return;
    }
    if (!drcContract) {
        alert("Connect your wallet first!");
        return;
    }
    try {
        const tx = await drcContract.buy({ value: ethers.utils.parseEther(amount) });
        await tx.wait();
        alert("DRC purchased successfully!");
        await displayBalance();
    } catch (err) {
        console.error(err);
        alert("Transaction failed!");
    }
}

// Event listeners
connectWalletBtn.addEventListener("click", connectWallet);
buyBtn.addEventListener("click", buyDRC);

// Auto-connect cached wallet
if (web3Modal.cachedProvider) {
    connectWallet();
}
