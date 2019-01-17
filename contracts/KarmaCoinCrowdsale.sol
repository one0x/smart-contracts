pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';


contract KarmaCoinCrowdsale is TimedCrowdsale, MintedCrowdsale {
	constructor (
		uint256 _openingTime,
		uint256 _closingTime,
		uint256 _rate,
		address _wallet,
		MintableToken _token
	) public TimedCrowdsale(_openingTime, _closingTime) Crowdsale(_rate, _wallet, _token) {

	}
}
