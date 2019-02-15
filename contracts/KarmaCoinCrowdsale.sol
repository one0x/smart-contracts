pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol';
import 'openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import 'openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';


contract KarmaCoinCrowdsale is TimedCrowdsale, MintedCrowdsale {
	constructor (
		uint256 _openingTime,
		uint256 _closingTime,
		uint256 _rate,
		address payable _wallet,
		ERC20Mintable _token
	) public TimedCrowdsale(_openingTime, _closingTime) Crowdsale(_rate, _wallet, _token) {

	}
}
