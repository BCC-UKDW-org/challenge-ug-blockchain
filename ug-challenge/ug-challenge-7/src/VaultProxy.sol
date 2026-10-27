// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VaultProxy
/// @notice Proxy minimal bergaya UUPS. Semua panggilan diteruskan ke implementation lewat `delegatecall`,
///         sehingga state disimpan di proxy, sedangkan logika ada di implementation.
/// @dev Alamat implementation disimpan di slot EIP-1967 supaya tidak bertabrakan dengan state implementation.
///      Logika upgrade ada di implementation (`upgradeTo`), bukan di proxy.
contract VaultProxy {
    /// @dev bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation) {
        require(implementation.code.length > 0, "VaultProxy: not a contract");
        assembly {
            sstore(IMPLEMENTATION_SLOT, implementation)
        }
    }

    /// @notice Alamat implementation yang sedang aktif.
    function getImplementation() external view returns (address implementation) {
        assembly {
            implementation := sload(IMPLEMENTATION_SLOT)
        }
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function _delegate() internal {
        assembly {
            let implementation := sload(IMPLEMENTATION_SLOT)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
