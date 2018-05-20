pragma solidity 0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';

contract KarmaCoin is BurnableToken, MintableToken, CappedToken {
	string public name = "KARMA KNOWLEDGE COIN";
	string public symbol = "KKC";
	uint8 public decimals = 18;

	function KarmaCoin(
		uint256 _cap,
		address scholarshipAddress,
		uint256 scholarshipAmount
	) public CappedToken(_cap) {
		// Code for karma coin contract
		// After karma contract is created, we need to transfer 1 Cr tokens to global scholarship account
		mint(scholarshipAddress, scholarshipAmount);
	}

	function burnFrom(address _account, uint256 _value) public {
		require(_value <= balances[_account]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure

		address burner = _account;
		balances[burner] = balances[burner].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		Burn(burner, _value);
		Transfer(burner, address(0), _value);
	}


}