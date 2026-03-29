// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./ERC20.sol";
import "./EIP712.sol";
import "./IERC20.sol";

/**
 * @dev ERC20 extension allowing approvals to be made via signatures, as defined in EIP-2612.
 */
abstract contract ERC20Permit is ERC20, EIP712 {
    mapping(address => uint256) private _nonces;

    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {}

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) public {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }
}
