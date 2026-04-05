const connectBtn = document.getElementById("connectWalletBtn");
const buyBtn = document.getElementById("buyBtn");

let provider, signer;

async function connectWallet() {
    if (!window.ethereum) return alert("Install MetaMask");

    await window.ethereum.request({ method: "eth_requestAccounts" });

    provider = new ethers.providers.Web3Provider(window.ethereum);
    signer = provider.getSigner();

    const address = await signer.getAddress();
    connectBtn.innerText = address.slice(0,6) + "...";
}

async function buyDRC() {
    const amount = document.getElementById("amount").value;

    if (!amount) return alert("Enter amount");

    const contractAddress = "YOUR_CONTRACT_ADDRESS";
    const abi = ["function buy() payable"];

    const contract = new ethers.Contract(contractAddress, abi, signer);

    try {
        const tx = await contract.buy({
            value: ethers.utils.parseEther(amount)
        });

        await tx.wait();
        alert("Purchase successful!");
    } catch {
        alert("Transaction failed");
    }
}

connectBtn.onclick = connectWallet;
buyBtn.onclick = buyDRC;
