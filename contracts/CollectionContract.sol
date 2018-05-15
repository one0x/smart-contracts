pragma solidity 0.4.23;

import './Collection/BaseCollection.sol';

contract CollectionContract is BaseCollection {

	function CollectionContract(
		KarmaCoin _karma,
		GyanCoin _gyan
	) public BaseCollection(_karma, _gyan) {
		// basic functions here

	}

}