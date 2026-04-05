// CONNECT WALLET
document.getElementById("connectWalletBtn").onclick = async () => {
  if (window.ethereum) {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    alert("Wallet Connected");
  } else {
    alert("Please install MetaMask");
  }
};

// NETWORK CHECK
async function checkNetwork() {
  if (window.ethereum) {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const network = await provider.getNetwork();

    if (network.chainId !== 56) {
      console.log("Switch to BNB Smart Chain");
    }
  }
}
checkNetwork();

// BUY FUNCTION
function buyDRC() {
  const tokenAddress = "0x6eBbc9CDBb7b3fc16e117f121eC55a16f5B645fF";
  window.open(
    `https://pancakeswap.finance/swap?outputCurrency=${tokenAddress}`,
    "_blank"
  );
}

// LIVE PRICE (CoinGecko)
async function loadPrice() {
  try {
    const res = await fetch(
      "https://api.coingecko.com/api/v3/simple/price?ids=binancecoin&vs_currencies=usd"
    );
    const data = await res.json();

    document.getElementById("price").innerText =
      "BNB Price: $" + data.binancecoin.usd;
  } catch {
    document.getElementById("price").innerText = "Price unavailable";
  }
}

loadPrice();
setInterval(loadPrice, 10000);
