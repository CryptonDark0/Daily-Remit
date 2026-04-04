// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IDEXRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract DailyRemitToken is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // ------------------ WALLET ADDRESSES ------------------
    address public devWallet = 0xAE1e1c414D88F5dF9dF3f75DE05924EBFFbDaA84;
    address public marketingWallet = 0xD346F0787e0FB3d21D7370E6708C55107BB0E150;

    // ------------------ SUPPLY ------------------
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;
    uint256 public constant MIN_SUPPLY = 100_000_000 * 10**18;

    // ------------------ FEES ------------------
    uint256 public burnFee = 100;       // 1%
    uint256 public devFee = 100;        // 1%
    uint256 public marketingFee = 100;  // 1%
    uint256 public constant MAX_FEE = 10000;

    // ------------------ SECURITY ------------------
    mapping(address => bool) public approvedRouters;

    // ------------------ EVENTS ------------------
    event SwapAndSendExecuted(address router, uint256 amountIn, address to);

    constructor() ERC20("DailyRemitToken", "DRT") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
    }

    // ------------------ ROUTER MANAGEMENT ------------------
    function setRouter(address router, bool status) external onlyOwner {
        approvedRouters[router] = status;
    }

    // ------------------ FEE MANAGEMENT ------------------
    function setFees(
        uint256 _burnFee,
        uint256 _devFee,
        uint256 _marketingFee
    ) external onlyOwner {
        require(_burnFee + _devFee + _marketingFee <= 1000, "Max 10%");
        burnFee = _burnFee;
        devFee = _devFee;
        marketingFee = _marketingFee;
    }

    // ------------------ BURN ------------------
    function burn(uint256 amount) external {
        require(totalSupply() - amount >= MIN_SUPPLY, "Below min supply");
        _burn(msg.sender, amount);
    }

    // ------------------ SWAP AND SEND (FIXED) ------------------
    // ------------------ SWAP AND SEND ------------------
function swapAndSend(
    address router,
    address to,
    uint256 amountIn,
    uint256 amountOutMin,
    address wrappedToken
) external onlyOwner nonReentrant whenNotPaused {

    require(amountIn > 0, "Invalid amount");
    require(router != address(0), "Invalid router");
    require(to != address(0), "Invalid recipient");
    require(wrappedToken != address(0), "Invalid wrapped token");
    require(amountOutMin > 0, "amountOutMin must be > 0");
    require(balanceOf(address(this)) >= amountIn, "Insufficient balance");
    require(approvedRouters[router], "Router not approved");

    // Approve tokens
    IERC20(address(this)).safeApprove(router, 0);
    IERC20(address(this)).safeApprove(router, amountIn);

    // ✅ FIXED: Declare swapPath properly in memory
    swapPath[0] = address(this);   // your token
    swapPath[1] = wrappedToken;    // wrapped token (WBNB, WETH, etc.)

    // Execute swap
    IDEXRouter(router).swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        swapPath,
        to,
        block.timestamp
    );

    emit SwapAndSendExecuted(router, amountIn, to);
}
    // ------------------ PAUSE CONTROL ------------------
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // ------------------ INTERNAL FEE LOGIC (OPTIONAL USE) ------------------
    function _transfer(address from, address to, uint256 amount) internal override {
        if (from == owner() || to == owner()) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 burnAmount = (amount * burnFee) / MAX_FEE;
        uint256 devAmount = (amount * devFee) / MAX_FEE;
        uint256 marketingAmount = (amount * marketingFee) / MAX_FEE;

        uint256 sendAmount = amount - burnAmount - devAmount - marketingAmount;

        if (burnAmount > 0 && totalSupply() > MIN_SUPPLY) {
            _burn(from, burnAmount);
        }

        if (devAmount > 0) {
            super._transfer(from, devWallet, devAmount);
        }

        if (marketingAmount > 0) {
            super._transfer(from, marketingWallet, marketingAmount);
        }

        super._transfer(from, to, sendAmount);
    }
}