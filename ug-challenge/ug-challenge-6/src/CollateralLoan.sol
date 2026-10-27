// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockToken} from "./mocks/MockToken.sol";
import {SimpleAMM} from "./SimpleAMM.sol";

/// @title CollateralLoan
/// @notice Pinjam WETH dengan jaminan TOKEN. Pengguna boleh meminjam maksimal 50% dari
///         nilai jaminannya (LTV 50%). Nilai jaminan harus mencerminkan harga pasar yang wajar
///         supaya protokol tidak pernah memberi pinjaman melebihi nilai jaminan.
/// @dev Disederhanakan: tidak ada bunga dan tidak ada likuidasi. WETH yang dipinjamkan
///      disediakan oleh treasury protokol (ditransfer langsung ke kontrak ini).
contract CollateralLoan {
    uint256 public constant LTV_PERCENT = 50;

    MockToken public immutable weth;
    MockToken public immutable token;
    SimpleAMM public immutable amm;

    mapping(address => uint256) public collateralOf;
    mapping(address => uint256) public debtOf;

    constructor(MockToken weth_, MockToken token_, SimpleAMM amm_) {
        weth = weth_;
        token = token_;
        amm = amm_;
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "CollateralLoan: zero amount");
        collateralOf[msg.sender] += amount;
        require(token.transferFrom(msg.sender, address(this), amount), "CollateralLoan: transfer failed");
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "CollateralLoan: zero amount");
        debtOf[msg.sender] += amount;
        require(debtOf[msg.sender] <= maxBorrow(msg.sender), "CollateralLoan: undercollateralized");
        require(weth.transfer(msg.sender, amount), "CollateralLoan: transfer failed");
    }

    function repay(uint256 amount) external {
        debtOf[msg.sender] -= amount;
        require(weth.transferFrom(msg.sender, address(this), amount), "CollateralLoan: transfer failed");
    }

    function withdrawCollateral(uint256 amount) external {
        collateralOf[msg.sender] -= amount;
        require(debtOf[msg.sender] <= maxBorrow(msg.sender), "CollateralLoan: undercollateralized");
        require(token.transfer(msg.sender, amount), "CollateralLoan: transfer failed");
    }

    /// @notice Harga 1 TOKEN dalam WETH (presisi 1e18).
    function getPrice() public view returns (uint256) {
        return amm.getSpotPriceTokenInWeth();
    }

    function collateralValueInWeth(address user) public view returns (uint256) {
        return collateralOf[user] * getPrice() / 1e18;
    }

    function maxBorrow(address user) public view returns (uint256) {
        return collateralValueInWeth(user) * LTV_PERCENT / 100;
    }
}
