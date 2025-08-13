// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";

contract ComplimentHook is BaseHook {
    string public constant COMPLIMENT_1 = "Nice one!";
    string public constant COMPLIMENT_2 = "Good job!";
    string public constant COMPLIMENT_3 = "Well done!";
    string public constant COMPLIMENT_4 = "Keep it up!";
    string public constant COMPLIMENT_5 = "Good work!";
    string public constant COMPLIMENT_6 = "Excellent!";
    string public constant COMPLIMENT_7 = "Great!";
    string public constant COMPLIMENT_8 = "Superb!";
    string public constant COMPLIMENT_9 = "Outstanding!";
    string public constant COMPLIMENT_10 = "Magnificent!";

    error BadSender();

    event Compliment(address indexed sender, string compliment);

    constructor(IPoolManager _manager) payable BaseHook(_manager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterAddLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _afterAddLiquidity(
        address,
        PoolKey calldata poolKey,
        ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata hookData
    ) internal override returns (bytes4, BalanceDelta) {
        address sender = abi.decode(hookData, (address));
        if (sender == address(0)) revert BadSender();

        uint256 compliment = (block.prevrandao ^ uint256(PoolId.unwrap(poolKey.toId())) ^ uint160(sender)) % 10;
        emit Compliment(sender, _pickCompliment(compliment));
        return (this.afterAddLiquidity.selector, BalanceDeltaLibrary.ZERO_DELTA);
    }

    function _pickCompliment(uint256 _compliment) internal pure returns (string memory) {
        if (_compliment < 5) {
            if (_compliment < 3) {
                if (_compliment == 0) return COMPLIMENT_1;
                else if (_compliment == 1) return COMPLIMENT_2;
                else return COMPLIMENT_3;
            } else {
                if (_compliment == 3) return COMPLIMENT_4;
                else return COMPLIMENT_5;
            }
        } else {
            if (_compliment < 7) {
                if (_compliment == 5) return COMPLIMENT_6;
                else return COMPLIMENT_7;
            } else {
                if (_compliment == 7) return COMPLIMENT_8;
                else if (_compliment == 8) return COMPLIMENT_9;
                else return COMPLIMENT_10;
            }
        }
    }
}
