
contract opXOnsBTCUSDTBSC is ReentrancyGuard {
    using SafeERC20 for IERC20;    
    IERC20 public USDTToken; 
    IERC20 public BTCToken; 
    address public beneficiary;
    uint64 public holdDuration;
    uint64 public maxTimeToWithdraw;
    address payable public feeAddress;
    uint256 public feePercentage;
    uint256 public releaseTime;
    uint256 public btcAmount;
    uint256 public marketPrice;
    uint256 public strikePrice;
    uint256 public bnbFees;
    bool public isActive = false;
    AggregatorV3Interface internal priceBTCUSDFeed;
    AggregatorV3Interface internal priceBNBUSDFeed;
    constructor(
        uint64 _holdDurationInDays,
        uint64 _maxTimeToWithdrawHours,
        uint256 _btcAmount, 
        uint256 _feePercentage
    ) {
        require(_holdDurationInDays > 0, "Duration days should be in the future.");
        require(_maxTimeToWithdrawHours > 1, "Timeframe to withdraw.");
        require(_btcAmount > 0, "Must be over 0.");
        require(_feePercentage > 0 && _feePercentage <= 100, "Invalid fee percentage");
        priceBTCUSDFeed = AggregatorV3Interface(address(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf));
        priceBNBUSDFeed = AggregatorV3Interface(address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE));
        USDTToken = IERC20(0x5DF0Aa30a59e1304E8dbb00b50343854E7168216);
        BTCToken = IERC20(0x0B56f3DE6726860D49a63c2E683f0967344E8410);
        btcAmount = _btcAmount;
        feePercentage = _feePercentage;
        holdDuration = _holdDurationInDays * 86400;
        maxTimeToWithdraw = _maxTimeToWithdrawHours * 3600;
        feeAddress = payable (msg.sender);
        isActive = true;
    }
    function buyOption() public payable {
        require(isActive = true);
        require(beneficiary == 0x0000000000000000000000000000000000000000, "the option has already been bought.");
        (, int _priceBTC, , ,) = priceBTCUSDFeed.latestRoundData();
        (, int _priceBNB, , ,) = priceBNBUSDFeed.latestRoundData();
        uint256 _marketPrice = uint256(_priceBTC);
        uint256 _strikePrice = (_marketPrice * btcAmount) / 100000000;
        uint256 _bnbFees = _strikePrice * feePercentage * 1000000 / uint256(_priceBNB);
        require (msg.value > _bnbFees);
        beneficiary = msg.sender;
        releaseTime = block.timestamp + holdDuration;
        marketPrice = _marketPrice;
        strikePrice = _strikePrice;
        // token1.safeTransfer(feeAddress, feeAmount1);
        feeAddress.transfer(msg.value);
    }
    function balanceOfBTC() public view returns (uint256) {
        return BTCToken.balanceOf(address(this));
    }
    function balanceOfUSDT() public view returns (uint256) {
        return USDTToken.balanceOf(address(this));
    }
    function release() public nonReentrant {
        require(isActive = true);
        require(block.timestamp >= releaseTime, "Release time is not due yet.");
        require(block.timestamp <= releaseTime + maxTimeToWithdraw, "You have will not be abel to withdraw after maximum time has passed.");
        uint256 amountOfUSDT = balanceOfUSDT();
        require(amountOfUSDT >= strikePrice, "You did not transfer the required amount of USDT to claim your BTC.");
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Withdraw.");
        BTCToken.safeTransfer(beneficiary, amountOfBTC);
        USDTToken.safeTransfer(feeAddress, amountOfUSDT);
    }
    function refundAll() public {
        require(isActive = true);
        require(msg.sender == feeAddress);
        require(block.timestamp > releaseTime + maxTimeToWithdraw, "The buyer still have a time.");
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Refund.");
        require(beneficiary != 0x0000000000000000000000000000000000000000);
        BTCToken.safeTransfer(feeAddress, amountOfBTC);
        uint256 amountOfUSDT = balanceOfUSDT();
        if (amountOfUSDT > 0) {
            USDTToken.safeTransfer(feeAddress, amountOfUSDT);
        }
    }
    function closeContract() public {
        require(isActive = true);
        require(msg.sender == feeAddress);
        uint256 amountOfBTC = balanceOfBTC();
        require(amountOfBTC >= 0, "There is no BTC to Refund");
        require(beneficiary == 0x0000000000000000000000000000000000000000);
        BTCToken.safeTransfer(feeAddress, amountOfBTC);
        isActive = false;
    }

}
