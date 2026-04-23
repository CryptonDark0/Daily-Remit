import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

function App() {
  const [walletAddress, setWalletAddress] = useState(null);
  const [drcBalance, setDrcBalance] = useState("0.00");
  const [activeTab, setActiveTab] = useState("receive");
  const [recipient, setRecipient] = useState("");
  const [amount, setAmount] = useState("");
  const [statusMessage, setStatusMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const DRC_ADDRESS = "0x316a5e1f7d3a52083185261965685c15ae284627";
  const LOGO_URL = "https://raw.githubusercontent.com/CryptonDark0/Daily-Remit/main/assets/logo/drc_icon_512.png";
  
  const ERC20_ABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function transfer(address to, uint256 amount) returns (bool)"
  ];

  // Safe connection function (Stops "connection rejected" errors)
  const connectWallet = async () => {
    if (!window.ethereum) {
      alert("No Web3 wallet found! Please install MetaMask.");
      return;
    }
    try {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      if (accounts.length > 0) {
        setWalletAddress(accounts[0]);
      }
    } catch (err) {
      console.error("User rejected the request.");
    }
  };

  // Automatically fetch balance when address changes
  useEffect(() => {
    if (!walletAddress) return;
    
    const getBalance = async () => {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const contract = new ethers.Contract(DRC_ADDRESS, ERC20_ABI, provider);
        const rawBalance = await contract.balanceOf(walletAddress);
        setDrcBalance(ethers.utils.formatUnits(rawBalance, 18));
      } catch (err) {
        console.error("Error fetching balance");
      }
    };
    getBalance();
  }, [walletAddress]);

  const sendDRC = async () => {
    if (!recipient || !amount) return alert("Please fill in all fields.");
    setIsLoading(true);
    setStatusMessage("Processing transaction...");

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(DRC_ADDRESS, ERC20_ABI, signer);
      const tokenAmount = ethers.utils.parseUnits(amount, 18);

      const tx = await contract.transfer(recipient, tokenAmount, { gasLimit: 80000 });
      setStatusMessage("Waiting for BSC confirmation...");
      await tx.wait();
      
      setStatusMessage("Transaction Successful! ✅");
      setRecipient("");
      setAmount("");
      
      // Refresh balance
      const rawBalance = await contract.balanceOf(walletAddress);
      setDrcBalance(ethers.utils.formatUnits(rawBalance, 18));
    } catch (err) {
      setStatusMessage("Transaction failed or rejected.");
    } finally {
      setIsLoading(false);
    }
  };

  const copyAddress = () => {
    if(walletAddress) navigator.clipboard.writeText(walletAddress);
  };

  return (
    <div style={styles.container}>
      {/* Header */}
      <header style={styles.header}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <img src={LOGO_URL} alt="DRC Logo" style={{ width: '40px', height: '40px', borderRadius: '50%' }} />
          <h1 style={styles.logoText}>DRC Wallet</h1>
        </div>
        
        {!walletAddress ? (
          <button onClick={connectWallet} style={styles.connectBtn}>Connect Wallet</button>
        ) : (
          <div style={styles.addressBox} onClick={copyAddress} title="Click to copy address">
            {walletAddress.substring(0, 6)}...{walletAddress.substring(38, 42)}
          </div>
        )}
      </header>

      {/* Main Dashboard */}
      {walletAddress && (
        <div style={styles.mainContent}>
          <div style={styles.balanceCard}>
            <p style={styles.balanceLabel}>Total Balance</p>
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '15px' }}>
              <img src={LOGO_URL} alt="DRC" style={{ width: '50px', height: '50px', borderRadius: '50%' }} />
              <h2 style={styles.balanceAmount}>{Number(drcBalance).toLocaleString()}</h2>
            </div>
            <p style={styles.balanceTicker}>DRC</p>
          </div>

          <div style={styles.actionArea}>
            <div style={styles.tabContainer}>
              <button onClick={() => { setActiveTab("send"); setStatusMessage(""); }} style={{ ...styles.tabBtn, borderBottom: activeTab === 'send' ? '2px solid #F0B90B' : '2px solid transparent', color: activeTab === 'send' ? '#F0B90B' : '#888' }}>Send</button>
              <button onClick={() => { setActiveTab("receive"); setStatusMessage(""); }} style={{ ...styles.tabBtn, borderBottom: activeTab === 'receive' ? '2px solid #F0B90B' : '2px solid transparent', color: activeTab === 'receive' ? '#F0B90B' : '#888' }}>Receive</button>
            </div>

            <div style={styles.tabContent}>
              {activeTab === 'send' ? (
                <div style={styles.form}>
                  <input style={styles.input} type="text" placeholder="Recipient BNB Address (0x...)" value={recipient} onChange={(e) => setRecipient(e.target.value)} />
                  <input style={styles.input} type="text" placeholder="Amount to Send" value={amount} onChange={(e) => setAmount(e.target.value)} />
                  <button style={{ ...styles.sendBtn, opacity: isLoading ? 0.6 : 1 }} onClick={sendDRC} disabled={isLoading}>
                    {isLoading ? "Sending..." : "Send DRC"}
                  </button>
                  {statusMessage && <p style={styles.statusMsg}>{statusMessage}</p>}
                </div>
              ) : (
                <div style={styles.form}>
                  <p style={{ color: '#aaa', marginBottom: '10px' }}>Share your BNB Smart Chain address to receive DRC:</p>
                  <div style={styles.receiveAddressBox}>{walletAddress}</div>
                  <button style={styles.sendBtn} onClick={copyAddress}>Copy Address</button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Pre-connect Welcome Screen */}
      {!walletAddress && (
        <div style={styles.preConnect}>
          <img src={LOGO_URL} alt="DRC Logo" style={styles.welcomeLogo} />
          <h2 style={{ color: 'white', marginBottom: '10px' }}>Welcome to Daily Remit Coin</h2>
          <p style={{ color: '#888', maxWidth: '300px', textAlign: 'center' }}>Connect your wallet to access your DRC funds on the BNB Smart Chain.</p>
        </div>
      )}
    </div>
  );
}

const styles = {
  container: { minHeight: '100vh', backgroundColor: '#0b0e11', color: 'white', fontFamily: "'Segoe UI', Roboto, Helvetica, Arial, sans-serif" },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 30px', backgroundColor: '#1e2329', borderBottom: '1px solid #2b3139' },
  logoText: { fontSize: '20px', fontWeight: '600', margin: 0, color: 'white' },
  connectBtn: { backgroundColor: '#F0B90B', color: '#0b0e11', border: 'none', padding: '10px 20px', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' },
  addressBox: { backgroundColor: '#2b3139', padding: '10px 15px', borderRadius: '8px', fontSize: '14px', cursor: 'pointer', border: '1px solid #474d57' },
  
  mainContent: { maxWidth: '500px', margin: '40px auto', padding: '0 20px' },
  balanceCard: { background: 'linear-gradient(135deg, #1e2329 0%, #2b3139 100%)', borderRadius: '16px', padding: '30px', textAlign: 'center', border: '1px solid #474d57', boxShadow: '0 4px 20px rgba(0,0,0,0.3)' },
  balanceLabel: { color: '#848e9c', fontSize: '14px', margin: 0, textTransform: 'uppercase', letterSpacing: '1px' },
  balanceAmount: { color: '#F0B90B', fontSize: '48px', margin: 0, fontWeight: 'bold' },
  balanceTicker: { color: '#848e9c', fontSize: '18px', margin: '10px 0 0 0' },

  actionArea: { backgroundColor: '#1e2329', borderRadius: '16px', marginTop: '20px', border: '1px solid #2b3139', overflow: 'hidden' },
  tabContainer: { display: 'flex', borderBottom: '1px solid #2b3139' },
  tabBtn: { flex: 1, backgroundColor: 'transparent', border: 'none', padding: '15px', color: '#848e9c', fontSize: '16px', fontWeight: '500', cursor: 'pointer' },
  tabContent: { padding: '20px' },
  form: { display: 'flex', flexDirection: 'column', gap: '15px' },
  input: { width: '100%', padding: '14px', borderRadius: '8px', border: '1px solid #474d57', backgroundColor: '#2b3139', color: 'white', fontSize: '16px', outline: 'none', boxSizing: 'border-box' },
  sendBtn: { width: '100%', padding: '16px', borderRadius: '8px', border: 'none', backgroundColor: '#F0B90B', color: '#0b0e11', fontSize: '16px', fontWeight: 'bold', cursor: 'pointer' },
  statusMsg: { fontSize: '14px', color: '#F0B90B', textAlign: 'center', margin: 0 },
  receiveAddressBox: { width: '100%', padding: '14px', borderRadius: '8px', border: '1px solid #474d57', backgroundColor: '#0b0e11', color: '#848e9c', fontSize: '12px', wordBreak: 'break-all', textAlign: 'center', marginBottom: '10px' },
  
  preConnect: { display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '70vh' },
  welcomeLogo: { width: '120px', height: '120px', borderRadius: '20%', marginBottom: '20px', boxShadow: '0 0 30px rgba(240, 185, 11, 0.3)' }
};

export default App;