// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @dev Provides information about the current execution context, including
 * the sender of the transaction and its data. While these are generally
 * available via msg.sender and msg.data, they should not be accessed directly
 * in case meta-transactions are used.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
