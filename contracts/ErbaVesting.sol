pragma solidity 0.6.2;

import "./FixedSupplyERC223.sol";
import "./Ownable.sol";

contract ErbaVesting is Ownable
{
	uint256 public VESTING_START_TIME = 1587340800; // 20 April 2020 @ 12:00am (UTC)
	uint256 public VESTING_END_TIME = 1681948800; // 20 April 2023 @ 12:00am (UTC)
	address public token;

	struct VestingDetail
	{
		uint256 amount;
		uint256 isActive;
	}

	mapping (address => VestingDetail) vestingDetails;

	event NewScheduleAdded(address beneficiary);
	event ReceivedTokens(address from, uint256 amount, bytes data);
	event WithdrawTokens(address to, uint256 amount);

	constructor(address _tokenContract) public
	{
		token = _tokenContract;
	}

	function createVestingSchedule(address _beneficiary, uint256 _amount) private
	{
		require(vestingDetails[_beneficiary].isActive == 0);
		vestingDetails[_beneficiary] = VestingDetail(_amount, 1);
		emit NewScheduleAdded(_beneficiary);
	}

	function withdrawTokens() external
	{
		require(now >= VESTING_END_TIME);

		VestingDetail memory userData = vestingDetails[msg.sender];
		require(userData.isActive == 1);

		userData.isActive = 0;
		FixedSupplyERC223(token).transfer(msg.sender, userData.amount, "Team Vesting Tokens");
		emit WithdrawTokens(msg.sender, userData.amount);
	}

	function tokenFallback(address _from, uint256 _value, bytes calldata _data) external
	{
		require(msg.sender == token);
		require(now < VESTING_END_TIME);

		emit ReceivedTokens(_from, _value, _data);
	}

	function infoBeneficiary(address _beneficiary) external view returns (uint256, uint256, uint256, uint256)
	{
		VestingDetail memory userData = vestingDetails[_beneficiary];
		if(userData.isActive == 1)
			return (VESTING_START_TIME, VESTING_END_TIME, userData.amount, userData.isActive);
		return (0, 0, 0, 0);
	}

	function selfBalance() external view returns (uint256)
	{
		return FixedSupplyERC223(token).balanceOf(address(this));
	}

	function createVestings() external onlyOwner
	{
		uint256 power =  FixedSupplyERC223(token).DECIMALS_MULTIPLIER();
		require(FixedSupplyERC223(token).balanceOf(address(this)) == 2000000 * power);

		createVestingSchedule(0xf0b08dEea570D9D11b35De05C3A268a7FB4a2b9F, 900000 * power);
		createVestingSchedule(0x0C2e90103029979434B16b15d5Aa629655d87851, 800000 * power);
		createVestingSchedule(0x01571B9720D7B60dA22cfC214B5343C83E2CBdcf, 200000 * power);
		createVestingSchedule(0x5EC1206363d6adB56d40Ec26c23ec8A31b0847cf, 50000 * power);
		createVestingSchedule(0xd57D4c63a2C38920d9831ECda2466fcFeE9161B5, 50000 * power);
	}

	function timeTillWithdraw() external view returns (uint256)
	{
		if(now >= VESTING_END_TIME)
			return 0;
		return VESTING_END_TIME - now;
	}

	function kill() external onlyOwner
	{
		selfdestruct(payable(owner));
	}
}
