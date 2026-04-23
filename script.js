// CONNECT WALLET
document.getElementById("connectWalletBtn").onclick = async () => {
  if (window.ethereum) {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    alert("Wallet Connected Successfully!");
  } else {
    alert("Please install MetaMask!");
  }
};

// BUY (PancakeSwap)
function buyDRC() {
  const tokenAddress = "YOUR_TOKEN_ADDRESS";
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
  } catch (e) {
    document.getElementById("price").innerText = "Price unavailable";
  }
}

loadPrice();
setInterval(loadPrice, 15000);
