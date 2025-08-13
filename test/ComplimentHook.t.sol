// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ComplimentHook} from "../src/ComplimentHook.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";

contract ComplimentHookTest is Test, Deployers {
    address immutable user = vm.addr(1);

    ComplimentHook hook;
    MockERC20 token0;
    MockERC20 token1;

    function setUp() public {
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();

        token0 = MockERC20(Currency.unwrap(currency0));
        token1 = MockERC20(Currency.unwrap(currency1));

        uint160 flags = uint160(Hooks.AFTER_ADD_LIQUIDITY_FLAG);
        deployCodeTo("ComplimentHook.sol", abi.encode(manager), address(flags));
        hook = ComplimentHook(address(flags));

        (key,) = initPool(currency0, currency1, hook, 3000, SQRT_PRICE_1_1);
    }

    function test() public {
        vm.prevrandao(uint256(keccak256("prevrandao")));

        vm.expectEmit(true, false, false, true, address(hook));
        emit ComplimentHook.Compliment(address(this), hook.COMPLIMENT_1());
        _addLiquidity(address(this));

        vm.prevrandao(uint256(keccak256("another prevrandao")));
        vm.expectEmit(true, false, false, true, address(hook));
        emit ComplimentHook.Compliment(address(this), hook.COMPLIMENT_5());
        _addLiquidity(address(this));

        token0.transfer(user, 1000 ether);
        token1.transfer(user, 1000 ether);
        vm.startPrank(user);
        token0.approve(address(modifyLiquidityRouter), type(uint256).max);
        token1.approve(address(modifyLiquidityRouter), type(uint256).max);
        vm.expectEmit(true, false, false, true, address(hook));
        emit ComplimentHook.Compliment(user, hook.COMPLIMENT_4());
        _addLiquidity(user);
    }

    function _addLiquidity(address onBehalf) internal {
        uint256 liquidityDelta =
            LiquidityAmounts.getLiquidityForAmount0(SQRT_PRICE_1_1, TickMath.getSqrtPriceAtTick(120), 1000 ether);
        modifyLiquidityRouter.modifyLiquidity(
            key,
            ModifyLiquidityParams({
                tickLower: -120,
                tickUpper: 120,
                liquidityDelta: int256(liquidityDelta),
                salt: bytes32(0)
            }),
            abi.encode(onBehalf)
        );
    }
}
