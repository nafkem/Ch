// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenSwap {
    using SafeERC20 for IERC20;

    address public owner;

    mapping(address => bool) public tokens;
    mapping(address => mapping(address => uint256)) public exchangeRates;
    uint256 public decimals = 18;

    event SwapToken(
        address indexed _from,
        address indexed _to,
        address indexed _user,
        uint256 _fromAmount,
        uint256 _toAmount
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this action"
        );
        _;
    }

    function setExchangeRate(
        address _token1,
        address _token2,
        uint256 _rate1to2,
        uint256 _rate2to1
    ) external onlyOwner {
        require(tokens[_token1], "Token is not supported");
        require(tokens[_token2], "Token is not supported");
        require(_token1 != _token2, "Cannot swap same token");

        exchangeRates[_token1][_token2] = _rate1to2;
        exchangeRates[_token2][_token1] = _rate2to1;
    }

    function addToken(address _tokenAddress) public onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        tokens[_tokenAddress] = true;
    }

    function removeToken(address _tokenAddress) public onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        tokens[_tokenAddress] = false;
    }

    function swapToken(
        address _fromToken,
        address _toToken,
        uint256 _fromAmount
    ) public {
        require(tokens[_fromToken], "Token not supported");
        require(tokens[_toToken], "Token not supported");
        require(_fromToken != _toToken, "Cannot swap same token");

        uint256 toAmount = (_fromAmount * exchangeRates[_fromToken][_toToken]) /
            (10 ** decimals);
        IERC20 fromToken = IERC20(_fromToken);
        IERC20 toToken = IERC20(_toToken);

        fromToken.safeTransferFrom(msg.sender, address(this), _fromAmount);
        toToken.safeTransfer(msg.sender, toAmount);

        emit SwapToken(_fromToken, _toToken, msg.sender, _fromAmount, toAmount);
    }

    function getExchangeRate(
        address _fromToken,
        address _toToken
    ) public view returns (uint256) {
        require(tokens[_fromToken], "Token not supported");
        require(tokens[_toToken], "Token not supported");
        require(_fromToken != _toToken, "Cannot swap same token");
        return exchangeRates[_fromToken][_toToken];
    }
}
