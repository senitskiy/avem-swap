// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
// import "../libraries/BoringERC20.sol";
// import "https://github.com/boringcrypto/BoringSolidity/blob/master/contracts/libraries/BoringERC20.sol";
import "../boring/BoringERC20.sol";


interface IRewarder {
    using BoringERC20 for IERC20;
    function onSushiReward(uint256 pid, address user, address recipient, uint256 sushiAmount, uint256 newLpAmount) external;
    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (IERC20[] memory, uint256[] memory);
}
