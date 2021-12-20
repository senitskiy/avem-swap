// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../../boring/BoringERC20.sol";

library Lib {

    // / @notice Withdraws an amount of `token` from a user account.
    // / @param token_ The ERC-20 token to withdraw.
    // / @param from which user to pull the tokens.
    // / @param to which user to push the tokens.
    // / @param amount of tokens. Either one of `amount` or `share` needs to be supplied.
    // / @param share Like above, but `share` takes precedence over `amount`.
    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) public allowed(from) returns (uint256 amountOut, uint256 shareOut) {
        // Checks
        require(to != address(0), "BentoBox: to not set"); // To avoid a bad UI from burning funds

        // Effects
        IERC20 token = token_ == USE_ETHEREUM ? wethToken : token_;
        Rebase memory total = totals[token];
        if (share == 0) {
            // value of the share paid could be lower than the amount paid due to rounding, in that case, add a share (Always round up)
            share = total.toBase(amount, true);
        } else {
            // amount may be lower than the value of share due to rounding, that's ok
            amount = total.toElastic(share, false);
        }

        balanceOf[token][from] = balanceOf[token][from].sub(share);
        total.elastic = total.elastic.sub(amount.to128());
        total.base = total.base.sub(share.to128());
        // There have to be at least 1000 shares left to prevent reseting the share/amount ratio (unless it's fully emptied)
        require(total.base >= MINIMUM_SHARE_BALANCE || total.base == 0, "BentoBox: cannot empty");
        totals[token] = total;

        // Interactions
        if (token_ == USE_ETHEREUM) {
            // X2, X3: A revert or big gas usage in the WETH contract could block withdrawals, but WETH9 is fine.
            IWETH(address(wethToken)).withdraw(amount);
            // X2, X3: A revert or big gas usage could block, however, the to address is under control of the caller.
            (bool success, ) = to.call{value: amount}("");
            require(success, "BentoBox: ETH transfer failed");
        } else {
            // X2, X3: A malicious token could block withdrawal of just THAT token.
            //         masterContracts may want to take care not to rely on withdraw always succeeding.
            token.safeTransfer(to, amount);
        }
        emit LogWithdraw(token, from, to, amount, share);
        amountOut = amount;
        shareOut = share;
    }

}