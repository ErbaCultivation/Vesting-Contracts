pragma solidity 0.6.2;

abstract contract FixedSupplyERC223
{
		uint8 public constant decimals = 18;
		uint public constant DECIMALS_MULTIPLIER = 10**uint(decimals);

		function transfer(address to, uint256 value, bytes calldata data) virtual external;
		function balanceOf(address who) virtual external view returns (uint256);
}
