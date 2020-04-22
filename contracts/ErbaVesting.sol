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

	function withdrawMyTokens() external
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
		require(FixedSupplyERC223(token).balanceOf(address(this)) == 200000000 * power);

		createVestingSchedule(0x7B82F77F48CdB314D22df4368566124Fb31afB56, 100000000 * power);
		createVestingSchedule(0xF87b867276dFbCCD42F3cC4c6a726aa8dC3AB537, 50000000 * power);
		createVestingSchedule(0x1e6D3e8344A1001E57241DB72fdd5b8BB50079Ba, 25000000 * power);
		createVestingSchedule(0x68474680E30176a730722A581F1069b2E0E791a3, 25000000 * power);
		
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
