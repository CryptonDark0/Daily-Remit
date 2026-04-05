// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DailyRemitCoin is ERC20, Ownable {

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;

    address public marketingWallet = 0xD346F0787e0FB3d21D7370E6708C55107BB0E150;
    address public devWallet = 0xAE1e1c414D88F5dF9dF3f75DE05924EBFFbDaA84;
    address public liquidityWallet = 0x914138FF3011dEC94FaCd2C76792cECc820D4D33;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public marketingFee = 1;
    uint256 public devFee = 1;
    uint256 public liquidityFee = 1;
    uint256 public burnFee = 1;

    uint256 public constant MAX_TOTAL_FEE = 10;

    bool public tradingOpen = false;
    bool public locked = false;

    mapping(address => bool) public isExcludedFromFees;

    modifier notLocked() {
        require(!locked, "Settings locked");
        _;
    }

    constructor() ERC20("Daily Remit Coin", "DRC") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);

        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(this)] = true;
    }

    function _update(address from, address to, uint256 amount) internal override {

        if (from != address(0) && to != address(0)) {
            require(tradingOpen || from == owner(), "Trading not open");

            uint256 feeTotal = marketingFee + devFee + liquidityFee + burnFee;
            uint256 feeAmount = 0;

            if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
                feeAmount = (amount * feeTotal) / 100;
            }

            uint256 sendAmount = amount - feeAmount;

            super._update(from, to, sendAmount);

            if (feeAmount > 0) {
                uint256 marketingPart = (feeAmount * marketingFee) / feeTotal;
                uint256 devPart = (feeAmount * devFee) / feeTotal;
                uint256 liquidityPart = (feeAmount * liquidityFee) / feeTotal;
                uint256 burnPart = feeAmount - marketingPart - devPart - liquidityPart;

                if (marketingPart > 0)
                    super._update(from, marketingWallet, marketingPart);

                if (devPart > 0)
                    super._update(from, devWallet, devPart);

                if (liquidityPart > 0)
                    super._update(from, liquidityWallet, liquidityPart);

                if (burnPart > 0)
                    super._update(from, DEAD, burnPart);
            }

        } else {
            super._update(from, to, amount);
        }
    }

    function openTrading() external onlyOwner {
        tradingOpen = true;
    }

    function setWallets(address _marketing, address _dev, address _liquidity) external onlyOwner notLocked {
        marketingWallet = _marketing;
        devWallet = _dev;
        liquidityWallet = _liquidity;
    }

    function setFees(uint256 _marketing, uint256 _dev, uint256 _liquidity, uint256 _burn)
        external
        onlyOwner
        notLocked
    {
        uint256 total = _marketing + _dev + _liquidity + _burn;
        require(total <= MAX_TOTAL_FEE, "Too high");

        marketingFee = _marketing;
        devFee = _dev;
        liquidityFee = _liquidity;
        burnFee = _burn;
    }

    function excludeFromFees(address user, bool state) external onlyOwner {
        isExcludedFromFees[user] = state;
    }

    function lockSettings() external onlyOwner {
        locked = true;
    }
}
