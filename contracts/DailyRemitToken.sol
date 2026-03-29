// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/security/ReentrancyGuard.sol";


interface IDEXRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract DailyRemitToken is ERC20, ERC20Votes, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Fee settings (basis points, 100 = 1%)
    uint256 public buybackFee;
    uint256 public burnFee;
    uint256 public devFee;
    uint256 public liquidityFee;
    uint256 public marketingFee;

    uint256 public constant MAX_FEE = 10000; // 100% in basis points

    // Wallets
    address public devWallet;
    address public marketingWallet;

    // Burn safeguard
    uint256 public constant MIN_SUPPLY = 100_000_000 * 10 ** 18; // stop burning if supply < 100M

    constructor()
        ERC20("DailyRemitToken", "DRT")
        ERC20Permit("DailyRemitToken") // required for ERC20Votes
        Ownable() // deployer becomes initial owner
    {
        // Mint 1 billion tokens to deployer
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());

        // Assign wallets
        devWallet = 0xAE1e1c414D88F5dF9dF3f75DE05924EBFFbDaA84;
        marketingWallet = 0xD346F0787e0FB3d21D7370E6708C55107BB0E150;

        // Default fees (balanced at 5% total)
        buybackFee   = 100; // 1%
        burnFee      = 100; // 1%
        devFee       = 100; // 1%
        liquidityFee = 100; // 1%
        marketingFee = 100; // 1%
    }

    modifier onlyFeeSetter() {
        require(msg.sender == owner(), "Only owner");
        _;
    }

    // --- Fee Management ---
    function setFees(
        uint256 _buybackFee,
        uint256 _burnFee,
        uint256 _devFee,
        uint256 _liquidityFee,
        uint256 _marketingFee
    ) external onlyFeeSetter {
        require(
            _buybackFee + _burnFee + _devFee + _liquidityFee + _marketingFee <= MAX_FEE,
            "Total fees must be <= 100%"
        );

        buybackFee   = _buybackFee;
        burnFee      = _burnFee;
        devFee       = _devFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
    }

    // --- Burn Mechanism with Safeguard ---
    function burn(uint256 amount) external {
        require(totalSupply() - amount >= MIN_SUPPLY, "Burn stopped: minimum supply reached");
        _burn(msg.sender, amount);
    }

    // --- Developer & Marketing Fund Transfers ---
    function distributeFees(uint256 amount) external onlyFeeSetter {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");
        uint256 devShare = (amount * devFee) / MAX_FEE;
        uint256 marketingShare = (amount * marketingFee) / MAX_FEE;
        uint256 burnShare = (amount * burnFee) / MAX_FEE;

        if (devShare > 0) IERC20(address(this)).safeTransfer(devWallet, devShare);
        if (marketingShare > 0) IERC20(address(this)).safeTransfer(marketingWallet, marketingShare);
        if (burnShare > 0 && totalSupply() - burnShare >= MIN_SUPPLY) {
            _burn(msg.sender, burnShare);
        }
    }

    // --- Swap Functionality with Slippage + Reentrancy Guard ---
    function swapAndSend(
        address _router,
        address _to,
        uint256 _amountIn,
        uint256 _amountOutMin, // slippage protection
        address _wrappedNative // WBNB for BSC, WETH for Ethereum
    ) external onlyFeeSetter nonReentrant {
        require(_amountIn > 0, "Amount must be > 0");
        require(_router != address(0), "Router address invalid");
        require(_to != address(0), "Recipient address invalid");
        require(_wrappedNative != address(0), "Wrapped native token invalid");

        IERC20(address(this)).safeIncreaseAllowance(_router, _amountIn);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _wrappedNative;

        IDEXRouter(_router).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    // --- Safety Features ---
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // --- Required Overrides for ERC20Votes ---
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20) // only ERC20 defines this
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes) // both define this
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes) // both define this
    {
        super._mint(to, amount);
    }

    function _burn(address from, uint256 amount)
        internal
        override(ERC20, ERC20Votes) // both define this
    {
        super._burn(from, amount);
    }
}
