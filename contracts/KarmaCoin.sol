pragma solidity ^0.4.24;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/CappedToken.sol';
import './ownership/rbac/RBAC.sol';

contract KarmaCoin is BurnableToken, MintableToken, CappedToken, RBAC {
	string public name = "KARMA KNOWLEDGE COIN";
	string public symbol = "KKC";
	uint8 public decimals = 18;

	constructor(
		uint256 _cap,
		address scholarshipAddress,
		uint256 scholarshipAmount,
		address foundersPoolAddress,
		address advisoryPoolAddress
	) public CappedToken(_cap) {
		// Code for karma coin contract
		// After karma contract is created, we need to transfer 100 Mil tokens to global scholarship account
		mint(scholarshipAddress, scholarshipAmount);
		// Transfer 100 Mil tokens to founders pool
		mint(foundersPoolAddress, 100000000);
		// Transfer 50 Mil tokens to advisory pool
		mint(advisoryPoolAddress, 50000000);
	}

	function mintFor(address _to, uint256 _amount) canMint public {
		totalSupply_ = totalSupply_.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(address(0), _to, _amount);
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
