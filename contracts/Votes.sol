// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./Context.sol";

/**
 * @dev Provides voting power tracking for governance.
 */
abstract contract Votes is Context {
    mapping(address => uint256) private _votes;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    function getVotes(address account) public view returns (uint256) {
        return _votes[account];
    }

    function _transferVotingUnits(address from, address to, uint256 amount) internal virtual {
        if (from != address(0)) {
            uint256 oldVotes = _votes[from];
            _votes[from] = oldVotes - amount;
            emit DelegateVotesChanged(from, oldVotes, _votes[from]);
        }
        if (to != address(0)) {
            uint256 oldVotes = _votes[to];
            _votes[to] = oldVotes + amount;
            emit DelegateVotesChanged(to, oldVotes, _votes[to]);
        }
    }
}
