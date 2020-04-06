pragma solidity 0.6.2;

contract Ownable
{
	address public owner;

	constructor() public
	{
		owner = msg.sender;
	}

	modifier onlyOwner
	{
		require(msg.sender == owner);
			_;
	}

	function transferOwnership(address newOwner) onlyOwner external
	{
		require(newOwner != address(0));
			owner = newOwner;
	}

}
