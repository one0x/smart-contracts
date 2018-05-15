pragma solidity 0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract GyanCoin is MintableToken {
	string public name = "GYAN";
	string public symbol = "GYN";
	uint8 public decimals = 18;

	function GyanCoin() public {

	}

	function mintFor(address _to, uint256 _amount) public {
		totalSupply_ = totalSupply_.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(address(0), _to, _amount);
	}

}