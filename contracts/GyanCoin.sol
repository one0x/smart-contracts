pragma solidity 0.4.23;

import "./KarmaCoin.sol";

contract GyanCoin {
	using SafeMath for uint256;

	string public name = "GYAN";
	string public symbol = "GYN";
	uint8 public decimals = 18;
	uint256 _yesterdayMint;
	uint256 _todayMint;
	uint256 _dailyStartTime;
	uint256 _weeklyStartTime;
	uint256 _currentDayNumber;
	mapping(uint256 => mapping(address => uint256)) dailyPeerBucket;
	mapping(uint256 => address[]) dailyPeerArray;

	KarmaCoin public karmaCoin;

	uint256 totalSupply_;
	struct Gyan {
		uint256 fixedBalance;
		uint256 floatingBalance;
		uint256[] timestampIndex;
		uint256 timestamp;
	}

	mapping(address => Gyan) gyanCoins;

	function GyanCoin(
		KarmaCoin _karma
	) public {
		require(_karma != address(0));

		karmaCoin = _karma;

		_dailyStartTime = now;
		_weeklyStartTime = now;
		_currentDayNumber = 1;
		_yesterdayMint = 1000; // Default starting Gyan mint rate on day 1
	}

	/**
    * @dev current rate of daily minted gyan coin
    */
	function yesterdayMint() public view returns (uint256) {
		return _yesterdayMint;
	}

	/**
    * @dev total supply of Gyan
    */
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

	function mintFor(address _to, uint256 _amount) public {
		if (dailyPeerBucket[_currentDayNumber][_to] == 0) {
			// User learning for the first time on this day of the current week
			// Added him to the day's bucket
			dailyPeerBucket[_currentDayNumber][_to] = _amount;
			dailyPeerArray[_currentDayNumber].push(_to);
		} else {
			// User learning again on the same day
			// Adding to his floating Gyan value of the day
			dailyPeerBucket[_currentDayNumber][_to] = dailyPeerBucket[_currentDayNumber][_to].add(_amount);
		}

		totalSupply_ = totalSupply_.add(_amount);
		gyanCoins[_to].floatingBalance = gyanCoins[_to].floatingBalance.add(_amount);
		gyanCoins[_to].timestampIndex.push(now);
		_todayMint = _todayMint.add(_amount);
	}

	function mintRewards() public returns (bool) {
		require(now >= _dailyStartTime + 1 days);
		// On Day Change
		if (now >= _dailyStartTime + 1 days) {
			_dailyStartTime = now;
			// Save the total mint count for yesterday and reset today's count
			_yesterdayMint = _todayMint;
			_todayMint = 0;
			// Change the day number of the week
			_currentDayNumber = _currentDayNumber.add(1);
			// On week change, reset day number to 1
			if (now >= _weeklyStartTime + 7 days) {
				_weeklyStartTime = now;
				_currentDayNumber = 1;
			}
			// Send out rewards to every peer who learnt last week
			// TODO: Currently rewarding everyone equally. Change to reward based on elliptic curve.
			for (uint i = 0; i < dailyPeerArray[_currentDayNumber].length; i++) {
				uint256 percentGyanEarnedToday = dailyFloatingBalanceOf(dailyPeerArray[_currentDayNumber][i], _currentDayNumber).mul(100).div(_yesterdayMint);
				// Reward user with Karma
				karmaCoin.mintFor(dailyPeerArray[_currentDayNumber][i], dailyKarmaMint().mul(65).div(100).mul(percentGyanEarnedToday).div(100));
				// Move Gyan from floating to fixed balance
				gyanCoins[dailyPeerArray[_currentDayNumber][i]].fixedBalance = gyanCoins[dailyPeerArray[_currentDayNumber][i]].fixedBalance.add(dailyFloatingBalanceOf(dailyPeerArray[_currentDayNumber][i], _currentDayNumber));
				gyanCoins[dailyPeerArray[_currentDayNumber][i]].floatingBalance = gyanCoins[dailyPeerArray[_currentDayNumber][i]].floatingBalance.sub(dailyFloatingBalanceOf(dailyPeerArray[_currentDayNumber][i], _currentDayNumber));
				delete dailyPeerBucket[_currentDayNumber][dailyPeerArray[_currentDayNumber][i]];
			}
			// Empty the buckets of the day
			delete dailyPeerArray[_currentDayNumber];
		}
		return true;
	}

	function dailyFloatingBalanceOf(address _owner, uint256 _currentDayNumber) internal returns (uint256) {
		return dailyPeerBucket[_currentDayNumber][_owner];
	}

	/**
	  * @dev Gets the daily karma minting value of the protocol.
	  * @return An uint256 representing the amount of karma minted everyday.
	  */
	function dailyKarmaMint() public view returns (uint256 dailyMint) {
		return (karmaCoin.totalSupply().mul(5).div(100)).div(365);
	}

	/**
	  * @dev Gets the average number of peers who are eligible for karma rewards every day over the last 7 days
	  * @return An uint256 representing the amount of karma minted everyday.
	  */
	function averageDailyPeers() public view returns (uint256 averagePeers) {
		return (dailyPeerArray[1].length + dailyPeerArray[2].length + dailyPeerArray[3].length + dailyPeerArray[4].length + dailyPeerArray[5].length + dailyPeerArray[6].length + dailyPeerArray[7].length).div(7);
	}

	/**
	  * @dev Gets the daily karma minting value of the protocol.
	  * @return An uint256 representing the amount of karma minted everyday.
	  */
	function potentialKarmaReward(address owner) public view returns (uint256) {
		uint256 karmaRewards = 0;
		for (uint i = 1; i <= 7; i++) {
			uint256 percentGyanEarnedToday = dailyPeerBucket[i][owner].mul(100).div(_yesterdayMint);
			karmaRewards = karmaRewards.add(dailyKarmaMint().mul(65).div(100).mul(percentGyanEarnedToday).div(100));
		}
		return karmaRewards;
	}

	/**
	  * @dev Gets the floating balance of the specified address.
	  * @param _owner The address to query the balance of.
	  * @return An uint256 representing the amount owned by the passed address.
	  */
	function floatingBalanceOf(address _owner) public view returns (uint256 balance) {
		return gyanCoins[_owner].floatingBalance;
	}

	/**
	  * @dev Gets the fixed balance of the specified address.
	  * @param _owner The address to query the balance of.
	  * @return An uint256 representing the amount owned by the passed address.
	  */
	function fixedBalanceOf(address _owner) public view returns (uint256 balance) {
		return gyanCoins[_owner].fixedBalance;
	}

}