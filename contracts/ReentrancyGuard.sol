// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to ensure there are no nested
 * (reentrant) calls.
 *
 * Note: Since `nonReentrant` prevents reentrancy across a single function,
 * you cannot mark a function as `nonReentrant` and then call another
 * `nonReentrant` function inside it. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant`
 * entry points to them.
 */
abstract contract ReentrancyGuard {
    // Status constants
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // Current status
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Applying this modifier to functions makes them non-reentrant.
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}
