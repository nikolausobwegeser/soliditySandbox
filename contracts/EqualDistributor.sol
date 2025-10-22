// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EqualDistributor
/// @notice Splits any received Ether equally between two predefined recipients.
contract EqualDistributor {
    address payable public immutable recipientA;
    address payable public immutable recipientB;

    event EtherDistributed(address indexed sender, uint256 amountEach);

    /// @param _recipientA First recipient that will receive half of every deposit.
    /// @param _recipientB Second recipient that will receive half of every deposit.
    constructor(address payable _recipientA, address payable _recipientB) {
        require(_recipientA != address(0), "Recipient A is zero address");
        require(_recipientB != address(0), "Recipient B is zero address");
        require(_recipientA != _recipientB, "Recipients must differ");

        recipientA = _recipientA;
        recipientB = _recipientB;
    }

    /// @notice Accepts Ether and forwards it equally to both recipients.
    /// @dev The transaction reverts if the value cannot be evenly split.
    receive() external payable {
        _distribute(msg.value);
    }

    /// @notice Handles direct calls with data and optional Ether.
    fallback() external payable {
        if (msg.value > 0) {
            _distribute(msg.value);
        } else {
            revert("Function not supported");
        }
    }

    /// @dev Handles splitting Ether between the recipients.
    function _distribute(uint256 amount) private {
        require(amount > 0, "No Ether supplied");
        require(amount % 2 == 0, "Uneven amount");

        uint256 share = amount / 2;

        (bool successA, ) = recipientA.call{value: share}("");
        require(successA, "Transfer to recipient A failed");

        (bool successB, ) = recipientB.call{value: share}("");
        require(successB, "Transfer to recipient B failed");

        emit EtherDistributed(msg.sender, share);
    }
}
