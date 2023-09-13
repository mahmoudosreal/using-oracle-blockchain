# opXOnsBTCUSDTBSC Smart Contract

This is a Solidity smart contract named `opXOnsBTCUSDTBSC`. The contract appears to be designed for handling options trading involving BTC (Bitcoin) and USDT (Tether) on the Binance Smart Chain (BSC). Below is an explanation of the contract's key features and functions.

## Contract Overview

The `opXOnsBTCUSDTBSC` contract includes the following state variables:

-   `USDTToken` and `BTCToken`: ERC20 token interfaces representing USDT and BTC.
-   `beneficiary`: Address of the option buyer.
-   `holdDuration`: The duration (in seconds) for which the option is held.
-   `maxTimeToWithdraw`: The maximum time (in seconds) allowed for the buyer to withdraw.
-   `feeAddress`: Address where fees are collected.
-   `feePercentage`: Percentage of the strike price to be collected as fees.
-   `releaseTime`: Timestamp indicating when the option can be released.
-   `btcAmount`: The amount of BTC involved in the option.
-   `marketPrice`: Current market price of BTC.
-   `strikePrice`: Strike price of the option.
-   `bnbFees`: Fees in BNB (Binance Coin) for the option.
-   `isActive`: Boolean indicating if the contract is active.

The contract also interacts with two external contracts (`AggregatorV3Interface` instances) to fetch price feeds for BTC/USD and BNB/USD.

## Constructor

The constructor initializes the contract with various parameters:

-   `_holdDurationInDays`: The duration of the option hold period in days.
-   `_maxTimeToWithdrawHours`: The maximum time allowed for withdrawal in hours.
-   `_btcAmount`: The amount of BTC involved in the option.
-   `_feePercentage`: The fee percentage to be collected.

## Functions

### `buyOption()`

This function is used by the option buyer to purchase the option. It performs the following actions:

-   Validates that the contract is active and the option has not already been bought.
-   Fetches the latest BTC and BNB prices from price feed contracts.
-   Calculates the strike price and fees in BNB.
-   Requires that the value sent with the transaction is greater than or equal to the fees in BNB.
-   Sets the beneficiary, release time, market price, strike price, and fee collection address.
-   Transfers the fees in BNB to the fee address.

### `balanceOfBTC()`

A view function that returns the balance of BTC tokens held by the contract.

### `balanceOfUSDT()`

A view function that returns the balance of USDT tokens held by the contract.

### `release()`

This function allows the beneficiary to release the option and claim the BTC. It enforces the following conditions:

-   The contract must be active.
-   The release time must have passed.
-   The withdrawal time must not have exceeded the maximum allowed time.
-   The contract must hold enough USDT to cover the strike price.
-   There must be BTC available for withdrawal.
-   Transfers the BTC to the beneficiary and USDT fees to the fee address.

### `refundAll()`

This function is used by the fee address to refund the buyer if the buyer fails to claim the option within the maximum withdrawal time. It checks:

-   The contract must be active.
-   The sender must be the fee address.
-   The buyer must have exceeded the maximum withdrawal time.
-   Transfers any remaining BTC to the fee address.
-   Transfers any remaining USDT to the fee address.

### `closeContract()`

This function allows the fee address to close the contract and retrieve any remaining BTC if the option has not been purchased. Conditions checked include:

-   The contract must be active.
-   The sender must be the fee address.
-   There must be remaining BTC.
-   The option must not have been purchased (beneficiary is zero).

## Notes

-   The contract appears to be designed for a specific use case and assumes that USDT and BTC tokens conform to the ERC20 standard.
-   Proper access control and security measures should be considered when using this contract in a real-world scenario.
-   It is essential to test and audit the contract thoroughly before deploying it on the Binance Smart Chain.
