pragma solidity ^0.4.23;

import './Collection/BaseCollection.sol';

contract CollectionContract is BaseCollection {

	constructor(
		KarmaCoin _karma,
		GyanCoin _gyan,
		ScholarshipContract _scholarships
	) public BaseCollection(_karma, _gyan, _scholarships) {
		// basic functions here

	}

}
