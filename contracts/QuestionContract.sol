pragma solidity ^0.5.0;

import './Question/BaseQuestion.sol';

contract QuestionContract is BaseQuestion {

	constructor(
		GyanCoin _gyan,
		KarmaCoin _karma,
		ScholarshipContract _scholarship
	) public BaseQuestion(_gyan, _karma, _scholarship) {
		// basic functions here

	}

}
