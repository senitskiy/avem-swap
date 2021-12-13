// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}