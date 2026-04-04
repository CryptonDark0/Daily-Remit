// Include ethers.js in your HTML <head> if not using npm
// <script src="https://cdn.jsdelivr.net/npm/ethers/dist/ethers.min.js"></script>
// <script src="https://cdn.jsdelivr.net/npm/@walletconnect/web3-provider/dist/umd/index.min.js"></script>

let provider;
let signer;
let userAddress;

// Connect MetaMask
async function connectMetaMask() {
    if (window.ethereum) {
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            userAddress = await signer.getAddress();
            alert("Connected MetaMask: " + userAddress);
        } catch (err) {
            console.error(err);
            alert("MetaMask connection failed!");
        }
    } else {
        alert("Install MetaMask!");
    }
}

// Connect WalletConnect
async function connectWalletConnect() {
    const WalletConnectProvider = window.WalletConnectProvider.default;
    const walletConnectProvider = new WalletConnectProvider({
        rpc: {
            56: "https://bsc-dataseed.binance.org/", // BSC Mainnet
            1: "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID" // Ethereum
        }
    });

    await walletConnectProvider.enable();
    provider = new ethers.providers.Web3Provider(walletConnectProvider);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();
    alert("Connected WalletConnect: " + userAddress);
}

// Buy DRC Example (call your contract)
async function buyDRC(amount) {
    const contractAddress = "YOUR_CONTRACT_ADDRESS";
    const abi = [
        "function buyTokens() payable" // Example function
    ];
    const contract = new ethers.Contract(contractAddress, abi, signer);

    try {
        const tx = await contract.buyTokens({ value: ethers.utils.parseEther(amount) });
        await tx.wait();
        alert("Purchase Successful!");
    } catch (err) {
        console.error(err);
        alert("Purchase Failed!");
    }
}
