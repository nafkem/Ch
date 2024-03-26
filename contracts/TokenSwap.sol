// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenSwap {
    address public owner;

    mapping(address => mapping(address => uint256)) public balances;

    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal linkEthPriceFeed;
    AggregatorV3Interface internal daiEthPriceFeed;

    event Swap(
        address indexed _fromToken,
        address indexed _toToken,
        address indexed _user,
        uint256 _amount
    );

    constructor(
        address _ethUsdPriceFeed,
        address _linkEthPriceFeed,
        address _daiEthPriceFeed
    ) {
        owner = msg.sender;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        linkEthPriceFeed = AggregatorV3Interface(_linkEthPriceFeed);
        daiEthPriceFeed = AggregatorV3Interface(_daiEthPriceFeed);
    }

    function swap(
        address _fromToken,
        address _toToken,
        uint256 _amount
    ) external {
        require(_fromToken != _toToken, "Cannot swap between the same token");

        uint256 fromTokenPrice = getPrice(_fromToken);
        uint256 toTokenPrice = getPrice(_toToken);

        uint256 fromBalance = balances[msg.sender][_fromToken];
        require(fromBalance >= _amount, "Insufficient balance");

        uint256 toAmount = (_amount * fromTokenPrice) / toTokenPrice;

        // Transfer tokens
        IERC20(_fromToken).transferFrom(msg.sender, address(this), _amount);
        IERC20(_toToken).transfer(msg.sender, toAmount);

        // Update balances
        balances[msg.sender][_fromToken] = fromBalance - _amount;
        balances[msg.sender][_toToken] += toAmount;

        emit Swap(_fromToken, _toToken, msg.sender, _amount);
    }

    function deposit(address _token, uint256 _amount) external {
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender][_token] += _amount;
    }

    function withdraw(address _token, uint256 _amount) external {
        IERC20 token = IERC20(_token);
        require(
            balances[msg.sender][_token] >= _amount,
            "Insufficient balance"
        );
        balances[msg.sender][_token] -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function getBalance(
        address _user,
        address _token
    ) external view returns (uint256) {
        return balances[_user][_token];
    }

    function getPrice(address _token) internal view returns (uint256) {
        if (_token == address(0)) {
            return 1e18; // ETH price is always 1
        } else if (_token == address(this)) {
            return 1e18; // Token price in relation to itself is always 1
        } else if (
            _token == address(0x514910771AF9Ca656af840dff83E8264EcF986CA)
        ) {
            // Chainlink LINK/ETH Price Feed
            (, int256 price, , , ) = linkEthPriceFeed.latestRoundData();
            return uint256(price);
        } else if (
            _token == address(0x6B175474E89094C44Da98b954EedeAC495271d0F)
        ) {
            // Chainlink DAI/ETH Price Feed
            (, int256 price, , , ) = daiEthPriceFeed.latestRoundData();
            return uint256(price);
        } else {
            revert("Unsupported token");
        }
    }
}
