pragma solidity ^0.4.23;

import "../GyanCoin.sol";
import "../KarmaCoin.sol";
import "../ScholarshipContract.sol";
import "../ownership/PbOwnable.sol";
import "../ownership/rbac/RBAC.sol";

contract BaseQuestion is PbOwnable, RBAC {

	using SafeMath for uint256;

	GyanCoin public gyanCoin;
	KarmaCoin public karmaCoin;
	ScholarshipContract public scholarshipContract;

	struct Question {
		bytes32 hash;
		bytes32 communityId;
		address owner;
		uint256 gyan;
		uint256 timestamp;
		bool open;
		mapping(bytes32 => Answer) answers;
		bytes32[] answerIndex;
		bytes32[] topics;
	}

	struct Answer {
		address owner;
		bytes32 hash;
		uint256 timestamp;
		bool status;
		bool flag;
	}

	mapping(bytes32 => Question) questions;

	event QuestionCreate(bytes32 _id, bytes32 _communityId, address _owner, bytes32 _hash, uint256 _gyan, bytes32[] _topics, uint256 _timestamp, address _pbNode);
	event QuestionAddAnswer(bytes32 _id, bytes32 _questionId, address _owner, bytes32 _hash, uint256 _timestamp, address pbNode);
	event QuestionAcceptAnswer(bytes32 _id, bytes32 _questionId, address pbNode);
	event QuestionClose(bytes32 _id, address pbNode);
	event QuestionFlagAnswer(bytes32 _id, bytes32 _questionId, address pbNode);
	event QuestionUnFlagAnswer(bytes32 _id, bytes32 _questionId, address pbNode);

	function BaseQuestion(
		GyanCoin _gyan,
		KarmaCoin _karma,
		ScholarshipContract _scholarship
	){
		require(_gyan != address(0));
		require(_karma != address(0));
		require(_scholarship != address(0));

		gyanCoin = _gyan;
		karmaCoin = _karma;
		scholarshipContract = _scholarship;
	}

	function create(bytes32 _id, bytes32 _communityId, address _owner, bytes32 _scholarshipId, bytes32 _hash, uint256 _gyan, bytes32[] _topics) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_id].timestamp == 0);
		require(_communityId[0] != 0);
		require(_owner != address(0));
		require(_hash[0] != 0);
		require(_gyan > 0);
		require(_topics.length > 0);
		require(_gyan <= gyanCoin.fixedBalanceOf(_owner) || _gyan == 1);    // check if enough gyan balance

		questions[_id].communityId = _communityId;
		questions[_id].owner = _owner;
		questions[_id].hash = _hash;
		questions[_id].gyan = _gyan;
		questions[_id].topics = _topics;
		questions[_id].timestamp = now;
		questions[_id].open = true;

		if (_scholarshipId == 'NA') {
			require(getKarmaToBurn(_gyan) <= karmaCoin.balanceOf(_owner));      // check if enough karma balance
			// Burn karma from peer wallet
			karmaCoin.burnFrom(_owner, getKarmaToBurn(_gyan));
		} else {
			require(scholarshipContract.getTimestamp(_scholarshipId) != 0);
			require(scholarshipContract.getType(_scholarshipId) == 0x7075626c69630000000000000000000000000000000000000000000000000000);   // Check if scholarship is public
			require(scholarshipContract.getParticipant(_scholarshipId, _owner) != 0);
			require(karmaCoin.balanceOf(scholarshipContract.getWalletAddress(_scholarshipId)) >= getKarmaToBurn(_gyan)); // check if this scholarship has enough karma balance
			// Burn karma from scholarship wallet
			karmaCoin.burnFrom(scholarshipContract.getWalletAddress(_scholarshipId), getKarmaToBurn(_gyan));
		}

		QuestionCreate(_id, _communityId, _owner, _hash, _gyan, _topics, now, msg.sender);
		return true;
	}

	function addAnswer(bytes32 _id, bytes32 _questionId, address _owner, bytes32 _hash) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_questionId].timestamp != 0);   // Question exists
		require(questions[_questionId].answers[_id].timestamp == 0);    // Answer does not exist
		require(_owner != address(0));
		require(questions[_questionId].open == true);
		require(_hash[0] != 0);

		questions[_questionId].answers[_id].owner = _owner;
		questions[_questionId].answers[_id].hash = _hash;
		questions[_questionId].answers[_id].timestamp = now;
		questions[_questionId].answerIndex.push(_id);

		QuestionAddAnswer(_id, _questionId, _owner, _hash, now, msg.sender);
		return true;
	}

	function acceptAnswer(bytes32 _id, bytes32 _questionId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_questionId].timestamp != 0);   // Question exists
		require(questions[_questionId].answers[_id].timestamp != 0);   // Answer exists
		require(questions[_questionId].answers[_id].status == false);
		require(questions[_questionId].answers[_id].flag == false);

		questions[_questionId].answers[_id].status = true;
		questions[_questionId].open = false;

		// Add gyan to answerer
		gyanCoin.mintFor(questions[_questionId].answers[_id].owner, questions[_questionId].gyan);
		// Add gyan to questioner
		gyanCoin.mintFor(questions[_questionId].owner, questions[_questionId].gyan);

		QuestionAcceptAnswer(_id, _questionId, msg.sender);
		return true;
	}

	function flagAnswer(bytes32 _id, bytes32 _questionId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_questionId].timestamp != 0);   // Question exists
		require(questions[_questionId].answers[_id].timestamp != 0);   // Answer exists
		require(questions[_questionId].answers[_id].flag == false);
		require(questions[_questionId].open == true);   // Question is open

		questions[_questionId].answers[_id].flag = true;

		QuestionFlagAnswer(_id, _questionId, msg.sender);
		return true;
	}

	function unFlagAnswer(bytes32 _id, bytes32 _questionId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_questionId].timestamp != 0);   // Question exists
		require(questions[_questionId].answers[_id].timestamp != 0);   // Answer exists
		require(questions[_questionId].answers[_id].flag == true);
		require(questions[_questionId].open == true);   // Question is open

		questions[_questionId].answers[_id].flag = false;

		QuestionUnFlagAnswer(_id, _questionId, msg.sender);
		return true;
	}

	function close(bytes32 _id) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(questions[_id].timestamp != 0);   // Question exists
		require(questions[_id].open == true);
		require(now >= questions[_id].timestamp + 1 days);  // Its been more than 24 hours since question was asked

		if (questions[_id].answerIndex.length > 0) {
			uint256 gyanPerAnswer = questions[_id].gyan.div(questions[_id].answerIndex.length);
			for(uint i = 0; i < questions[_id].answerIndex.length; i++) {
				if (questions[_id].answers[questions[_id].answerIndex[i]].flag != true) {
					// Add gyan to answerer
					gyanCoin.mintFor(questions[_id].answers[questions[_id].answerIndex[i]].owner, gyanPerAnswer);
					// Add gyan to questioner
					gyanCoin.mintFor(questions[_id].owner, gyanPerAnswer);
				}
			}
			questions[_id].open = false;
		} else {
			questions[_id].open = false;
		}

		QuestionClose(_id, msg.sender);
		return true;
	}

	function getQuestion(bytes32 _id) public view returns (bytes32, address, bytes32, uint256, bytes32[], uint256) {
		// Solidity does not yet support returning structs to web3
		return (questions[_id].communityId, questions[_id].owner, questions[_id].hash, questions[_id].gyan, questions[_id].topics, questions[_id].timestamp);
	}

	function getAnswers(bytes32 _id) public view returns (bytes32[]) {
		// Solidity does not yet support returning structs to web3
		return questions[_id].answerIndex;
	}


	// Pure functions

	function getKarmaToBurn(uint256 _gyan) public view returns (uint256) {
		//TODO : put logic here to dynamically calculate Karma value based on gyan
		uint256 dailyKarmaMint = (karmaCoin.totalSupply().mul(5).div(100)).div(365);
		uint256 dailyGyanEarn = gyanCoin.yesterdayMint();
		//uint256 dailyGyanEarn = 1000;
		return _gyan.mul(dailyKarmaMint.div(dailyGyanEarn));
	}

}
