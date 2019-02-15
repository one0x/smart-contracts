pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol';
import './ownership/rbac/RBAC.sol';

contract KarmaCoin is ERC20Detailed, ERC20Burnable, ERC20Mintable, ERC20Capped, RBAC {
	string public _name = "KARMA KNOWLEDGE COIN";
	string public _symbol = "KKC";
	uint8 public _decimals = 18;

	constructor(
		uint256 _cap,
		address scholarshipAddress,
		uint256 scholarshipAmount,
		address foundersPoolAddress,
		address advisoryPoolAddress,
		address communityPoolAddress
	) public ERC20Detailed(_name, _symbol, _decimals) ERC20Capped(_cap) {
		// Code for karma coin contract
		// After karma contract is created, we need to transfer 100 Mil tokens to global scholarship account
		mint(scholarshipAddress, scholarshipAmount);
		// Transfer 100 Mil tokens to founders pool
		mint(foundersPoolAddress, 100000000);
		// Transfer 50 Mil tokens to advisory pool
		mint(advisoryPoolAddress, 50000000);
		// Transfer 10 Mil tokens to community pool
		mint(communityPoolAddress, 10000000);
	}

	function transferFor(address _from, address _to, uint256 _amount) public {
		require(_to != address(0));
		require(_from != address(0));
		require(_amount <= _balances[_from]);

		// SafeMath.sub will throw if there is not enough balance.
		_balances[_from] = _balances[_from].sub(_amount);
		_balances[_to] = _balances[_to].add(_amount);
		emit Transfer(_from, _to, _amount);
	}

	function mintFor(address _to, uint256 _amount) onlyMinter public {
		_totalSupply = _totalSupply.add(_amount);
		_balances[_to] = _balances[_to].add(_amount);
		emit Transfer(address(0), _to, _amount);
	}

	function burnFrom(address _account, uint256 _value) public {
		require(_value <= _balances[_account]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure

		address burner = _account;
		_balances[burner] = _balances[burner].sub(_value);
		_totalSupply = _totalSupply.sub(_value);
		emit Transfer(burner, address(0), _value);
	}
}