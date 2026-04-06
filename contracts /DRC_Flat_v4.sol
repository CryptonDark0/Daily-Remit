// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// ─────────────────────────────────────────────────────────────────────────────
//  FLATTENED — Single file, no imports, BSCScan verification ready
//  Compiler : Solidity 0.8.26  |  Optimizer: ON (200 runs)
//  Network  : BNB Smart Chain (BSC)
//  Token    : Daily Remit Coin (DRC)
// ─────────────────────────────────────────────────────────────────────────────


// ── Context ───────────────────────────────────────────────────────────────────

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// ── IERC20 ────────────────────────────────────────────────────────────────────

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply()                             external view returns (uint256);
    function balanceOf(address account)                external view returns (uint256);
    function transfer(address to, uint256 value)       external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value)   external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// ── IERC20Metadata ────────────────────────────────────────────────────────────

interface IERC20Metadata is IERC20 {
    function name()     external view returns (string memory);
    function symbol()   external view returns (string memory);
    function decimals() external view returns (uint8);
}


// ── IERC20Errors ──────────────────────────────────────────────────────────────

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}


// ── Ownable ───────────────────────────────────────────────────────────────────

contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert OwnableInvalidOwner(address(0));
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        if (owner() != _msgSender()) revert OwnableUnauthorizedAccount(_msgSender());
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert OwnableInvalidOwner(address(0));
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// ── ERC20 ─────────────────────────────────────────────────────────────────────

contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string  private _name;
    string  private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name   = name_;
        _symbol = symbol_;
    }

    function name()        public view virtual returns (string memory) { return _name;   }
    function symbol()      public view virtual returns (string memory) { return _symbol; }
    function decimals()    public view virtual returns (uint8)         { return 18;       }
    function totalSupply() public view virtual returns (uint256)       { return _totalSupply; }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 value) public virtual returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        _spendAllowance(from, _msgSender(), value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) revert ERC20InvalidSender(address(0));
        if (to   == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(from, to, value);
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) revert ERC20InsufficientBalance(from, fromBalance, value);
            unchecked { _balances[from] = fromBalance - value; }
        }
        if (to == address(0)) {
            unchecked { _totalSupply -= value; }
        } else {
            unchecked { _balances[to] += value; }
        }
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual {
        if (account == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal virtual {
        if (account == address(0)) revert ERC20InvalidSender(address(0));
        _update(account, address(0), value);
    }

    function _approve(address owner_, address spender, uint256 value) internal virtual {
        if (owner_  == address(0)) revert ERC20InvalidApprover(address(0));
        if (spender == address(0)) revert ERC20InvalidSpender(address(0));
        _allowances[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _spendAllowance(address owner_, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value)
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            unchecked { _approve(owner_, spender, currentAllowance - value); }
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
//  Daily Remit Coin (DRC)
// ─────────────────────────────────────────────────────────────────────────────

contract DRC is ERC20, Ownable {

    // ── Constants ──────────────────────────────────────────────────────────────

    uint256 public constant MAX_SUPPLY    = 1_000_000_000 * 10 ** 18;
    uint256 public constant MAX_TOTAL_FEE = 10;
    address public constant DEAD          = 0x000000000000000000000000000000000000dEaD;

    // ── Fee Wallets ────────────────────────────────────────────────────────────

    address public marketingWallet = 0xD346F0787e0FB3d21D7370E6708C55107BB0E150;
    address public devWallet       = 0xAE1e1c414D88F5dF9dF3f75DE05924EBFFbDaA84;
    address public liquidityWallet = 0x914138FF3011dEC94FaCd2C76792cECc820D4D33;

    // ── Fee Percentages ────────────────────────────────────────────────────────

    uint256 public marketingFee = 1;
    uint256 public devFee       = 1;
    uint256 public liquidityFee = 1;
    uint256 public burnFee      = 1;

    // ── State ──────────────────────────────────────────────────────────────────

    bool public tradingOpen = false;
    bool public locked      = false;

    mapping(address => bool) public isExcludedFromFees;

    // ── DEX & Limits State ─────────────────────────────────────────────────────

    mapping(address => bool) public automatedMarketMakerPairs;
    uint256 public launchBlock;
    uint256 public constant DEAD_BLOCKS = 3; 
    uint256 public maxTransactionAmount = 20_000_000 * 10 ** 18; // 2% of supply
    uint256 public maxWalletAmount      = 20_000_000 * 10 ** 18; // 2% of supply
    bool public limitsActive            = true;

    // ── Custom Errors ──────────────────────────────────────────────────────────

    error TradingNotOpen();
    error AntiBotSniper();
    error ExceedsMaxTransaction();
    error ExceedsMaxWallet();
    error CannotExcludePair();

    // ── Events ─────────────────────────────────────────────────────────────────

    event TradingOpened();
    event SettingsLocked();
    event WalletsUpdated(address marketing, address dev, address liquidity);
    event FeesUpdated(uint256 marketing, uint256 dev, uint256 liquidity, uint256 burn);
    event ExclusionUpdated(address indexed user, bool state);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SupplyReduced(uint256 amountBurned); // Whitepaper Deflationary Event

    // ── Modifier ───────────────────────────────────────────────────────────────

    modifier notLocked() {
        require(!locked, "DRC: settings are locked");
        _;
    }

    // ── Constructor ────────────────────────────────────────────────────────────

    constructor()
        ERC20("Daily Remit Coin", "DRC")
        Ownable(msg.sender)
    {
        _mint(msg.sender, MAX_SUPPLY);
        
        // Exclude core addresses from fees
        isExcludedFromFees[msg.sender]      = true;
        isExcludedFromFees[address(this)]   = true;
        isExcludedFromFees[marketingWallet] = true;
        isExcludedFromFees[devWallet]       = true;
        isExcludedFromFees[liquidityWallet] = true;
    }

    // ── Transfer Hook with Fee Logic ───────────────────────────────────────────

    function _update(address from, address to, uint256 amount) internal override {
        // Mint / Burn paths — skip fees
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }

        require(tradingOpen || from == owner(), "DRC: trading not open yet");

        // Anti-Bot Protection (Blocks buys/sells for first 3 blocks after launch)
        if (launchBlock != 0 && block.number - launchBlock < DEAD_BLOCKS) {
            if (automatedMarketMakerPairs[from] && !isExcludedFromFees[to]) revert AntiBotSniper();
            if (automatedMarketMakerPairs[to] && !isExcludedFromFees[from]) revert AntiBotSniper();
        }

        // Max Transaction & Max Wallet Limits
        if (limitsActive && !isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            if (amount > maxTransactionAmount) revert ExceedsMaxTransaction();
            
            if (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) {
                if (balanceOf(to) + amount > maxWalletAmount) revert ExceedsMaxWallet();
            }
        }

        uint256 feeAmount = 0;

        // Only charge fees on DEX Buys/Sells (NOT normal wallet-to-wallet transfers)
        bool isBuy  = automatedMarketMakerPairs[from];
        bool isSell = automatedMarketMakerPairs[to];
        bool takeFee = !isExcludedFromFees[from] && !isExcludedFromFees[to] && (isBuy || isSell);

        if (takeFee) {
            uint256 feeTotal = marketingFee + devFee + liquidityFee + burnFee;

            if (feeTotal > 0) {
                feeAmount = (amount * feeTotal) / 100;

                uint256 marketingPart = (feeAmount * marketingFee)  / feeTotal;
                uint256 devPart       = (feeAmount * devFee)        / feeTotal;
                uint256 liquidityPart = (feeAmount * liquidityFee)  / feeTotal;
                uint256 burnPart      = feeAmount - marketingPart - devPart - liquidityPart;

                if (marketingPart > 0) super._update(from, marketingWallet, marketingPart);
                if (devPart       > 0) super._update(from, devWallet,       devPart);
                if (liquidityPart > 0) super._update(from, liquidityWallet, liquidityPart);
                
                if (burnPart > 0) {
                    super._update(from, DEAD, burnPart);
                    emit SupplyReduced(burnPart); // Emit explicit whitepaper event
                }
            }
        }

        super._update(from, to, amount - feeAmount);
    }

    // ── Owner Functions ────────────────────────────────────────────────────────

    /// @notice Permanently open trading — cannot be reversed
    function openTrading() external onlyOwner {
        tradingOpen = true;
        launchBlock = block.number;
        emit TradingOpened();
    }

    /// @notice Update fee destination wallets
    function setWallets(
        address _marketing,
        address _dev,
        address _liquidity
    ) external onlyOwner notLocked {
        require(
            _marketing != address(0) && _dev != address(0) && _liquidity != address(0),
            "DRC: zero address"
        );
        marketingWallet = _marketing;
        devWallet       = _dev;
        liquidityWallet = _liquidity;
        emit WalletsUpdated(_marketing, _dev, _liquidity);
    }

    /// @notice Adjust fee percentages — total cannot exceed MAX_TOTAL_FEE (10%)
    function setFees(
        uint256 _marketing,
        uint256 _dev,
        uint256 _liquidity,
        uint256 _burn
    ) external onlyOwner notLocked {
        require(
            _marketing + _dev + _liquidity + _burn <= MAX_TOTAL_FEE,
            "DRC: fees too high"
        );
        marketingFee  = _marketing;
        devFee        = _dev;
        liquidityFee  = _liquidity;
        burnFee       = _burn;
        emit FeesUpdated(_marketing, _dev, _liquidity, _burn);
    }

    /// @notice Exclude or include an address from transaction fees
    function excludeFromFees(address user, bool state) external onlyOwner {
        if (automatedMarketMakerPairs[user]) revert CannotExcludePair();
        isExcludedFromFees[user] = state;
        emit ExclusionUpdated(user, state);
    }

    /// @notice Set the PancakeSwap V2 Pair address (Call this AFTER adding liquidity)
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != address(this), "DRC: cannot set self as pair");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /// @notice Remove max transaction and max wallet limits permanently
    function removeLimits() external onlyOwner notLocked {
        limitsActive = false;
    }

    /// @notice Rescue accidentally sent BNB
    function rescueBNB() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "DRC: BNB transfer failed");
    }

    /// @notice Rescue accidentally sent ERC20 tokens
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(this), "DRC: cannot rescue self");
        IERC20(token).transfer(owner(), amount);
    }

    /// @notice Permanently lock wallet & fee settings
    function lockSettings() external onlyOwner {
        locked = true;
        emit SettingsLocked();
    }
}
