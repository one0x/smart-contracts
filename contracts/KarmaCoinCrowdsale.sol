pragma solidity 0.4.23;

import './KarmaCoin.sol';
import 'zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';


contract KarmaCoinCrowdsale is TimedCrowdsale, MintedCrowdsale {
	function KarmaCoinCrowdsale (
		uint256 _openingTime,
		uint256 _closingTime,
		uint256 _rate,
		address _wallet,
		MintableToken _token
	) public Crowdsale(_rate, _wallet, _token) TimedCrowdsale(_openingTime, _closingTime) {

	}
}