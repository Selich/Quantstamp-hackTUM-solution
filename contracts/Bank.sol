//SPDX-License-Identifier: Unlicense
pragma solidity 0.7.0;

import "./interfaces/IBank.sol";
import "./interfaces/IPriceOracle.sol";
import "hardhat/console.sol";

contract Bank is IBank {
    mapping(address => Account) private hakAccounts;
    mapping(address => Account) private ethAccounts;

    address private ethMagic = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private priceOracle;
    address private hakToken;

    constructor(address _priceOracle, address _hakToken) {
        require(_priceOracle != address(0));
        require(_hakToken != address(0));
        priceOracle = _priceOracle;
        hakToken = _hakToken;
        console.log("[Bank constructor] price oracle token %s, hak token %s", priceOracle, hakToken);
    }

    function deposit(address token, uint256 amount)
        payable
        external
        override
        returns (bool) {
        require(
            token == ethMagic || token == hakToken,
            "token not supported"
        );
        if (token == ethMagic) {
            console.log("[ETH] Trying to send %s tokens to %s", amount, token);
            ethAccounts[token].deposit += amount;
            ethAccounts[msg.sender].deposit -= amount;
        } else {
            console.log("[HAK] Trying to send %s tokens to %s", amount, token);
            hakAccounts[token].deposit += amount;
            hakAccounts[msg.sender].deposit -= amount;
        }
        console.log("msg.sender address", msg.sender);
        emit Deposit(msg.sender, token, amount);
        return true;
    }

    function withdraw(address token, uint256 amount)
        external
        override
        returns (uint256) {
        if (token == hakToken) {
            require(hakAccounts[token].deposit > amount);
            hakAccounts[token].deposit -= amount;
        } else {
            require(ethAccounts[token].deposit > amount);
            ethAccounts[token].deposit -= amount;
        }
    }

    function borrow(address token, uint256 amount)
        external
        override
        returns (uint256) {
            require(1 == 2, "no collateral deposited");
    }

    function repay(address token, uint256 amount)
        payable
        external
        override
        returns (uint256) {}

    function liquidate(address token, address account)
        payable
        external
        override
        returns (bool) {}

    function getCollateralRatio(address token, address account)
        view
        public
        override
        returns (uint256) {
        require(token != address(0));
        require(account != address(0));
    }

    function getBalance(address token)
        view
        public
        override
        returns (uint256) {
        if (token == ethMagic) {
            return ethAccounts[token].deposit;
        }
        return hakAccounts[token].deposit;
    }
}
