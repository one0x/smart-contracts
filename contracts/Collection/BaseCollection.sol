pragma solidity ^0.4.23;

import "./CollectionBasic.sol";
import "../KarmaCoin.sol";
import "../GyanCoin.sol";
import "../ScholarshipContract.sol";
import "../ownership/rbac/RBAC.sol";

/**
 * @title BaseCollection
 * @author Aakash Bansal @ one0x Inc.
 * @dev Basic version of collection contract
 * @dev Handled collection create, joining and assessment
 */
contract BaseCollection is CollectionBasic, PbOwnable, RBAC {

	using SafeMath for uint256;

	KarmaCoin public karmaCoin;
	GyanCoin public gyanCoin;
	ScholarshipContract public scholarshipContract;

	struct Collection {
		bytes32 _type;
		uint256 academicGyan;
		uint256 nonAcademicGyan;
		address teacher;
		uint256 timestamp;
		uint256 learningHours;
		mapping(address => uint256) participants;
		mapping(address => bytes32) hash;
		mapping(address => uint256) droppedParticipants;
		bytes32[] topics;
		address[] participantIndex;
		mapping(bytes32 => uint256) assessmentRules;
		uint256 engagementRule;
		uint256 commitmentRule;
		bytes32[] assessmentRuleKeys;
		uint256[] assessmentRuleValues;
		mapping(bytes32 => mapping(address => uint256)) results;
	}

	mapping(bytes32 => Collection) collections;

	event CollectionCreate(bytes32 _id, bytes32 _type, address pbNode);
	event CollectionJoin(bytes32 _id, address _participantAddress, address pbNode);
	event CollectionAssess(bytes32 _id, address _participantAddress, bytes32 _assessmentResult, uint256 academicGyan, uint256 engagementGyan, uint256 commitmentGyan, address pbNode);
	event CollectionDrop(bytes32 _id, address _participantAddress, address pbNode);

	constructor(KarmaCoin _karma, GyanCoin _gyan, ScholarshipContract _scholarships) {
		require(_karma != address(0));
		require(_gyan != address(0));
		require(_scholarships != address(0));

		karmaCoin = _karma;
		gyanCoin = _gyan;
		scholarshipContract = _scholarships;

	}

	function create(bytes32 _id, address _teacherAddress, bytes32 _type, uint256 _learningHours, uint256 _academicGyan, uint256 _nonAcademicGyan, bytes32[] _assessmentRuleKeys, uint256[] _assessmentRuleValues, uint256[] _nonAcademicRules, bytes32[] _topics) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(collections[_id].timestamp == 0);
		require(_teacherAddress != address(0));
		require(_type[0] != 0);
		require(_academicGyan > 0);
		require(_nonAcademicGyan > 0);
		require(_topics.length > 0);
		require(_learningHours > 0);
		require(_assessmentRuleKeys.length == _assessmentRuleValues.length);
		require(_academicGyan + _nonAcademicGyan <= gyanCoin.fixedBalanceOf(_teacherAddress) || _academicGyan + _nonAcademicGyan == _learningHours);

		collections[_id].teacher = _teacherAddress;
		collections[_id]._type = _type;
		collections[_id].academicGyan = _academicGyan;
		collections[_id].nonAcademicGyan = _nonAcademicGyan;
		collections[_id].timestamp = now;
		collections[_id].topics = _topics;
		collections[_id].learningHours = _learningHours;
		collections[_id].engagementRule = _nonAcademicRules[0];
		collections[_id].commitmentRule = _nonAcademicRules[1];
		// Map _assessmentRules array to contract variables
		for (uint i = 0; i < _assessmentRuleKeys.length; i++) {
			collections[_id].assessmentRules[_assessmentRuleKeys[i]] = _assessmentRuleValues[i];
			collections[_id].assessmentRuleKeys.push(_assessmentRuleKeys[i]);
		}
		CollectionCreate(_id, _type, msg.sender);
		return true;
	}

	function addHash(bytes32 _id, address _participantAddress, bytes32 _hash) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(_participantAddress != 0);
		require(collections[_id].timestamp != 0);
		require(collections[_id].hash[_participantAddress] == 0);
		require(collections[_id].participants[_participantAddress] != 0);
		require(_hash[0] != 0);

		collections[_id].hash[_participantAddress] = _hash;
		return true;
	}

	function getData(bytes32 _id) public view returns (bytes32, bytes32[], bytes32[], uint256, uint256, address, uint256) {
		// Solidity does not yet support returning structs to web3
		return (collections[_id]._type, collections[_id].topics, collections[_id].assessmentRuleKeys, collections[_id].academicGyan, collections[_id].nonAcademicGyan , collections[_id].teacher, collections[_id].timestamp);
	}

	function getTeacher(bytes32 _id) public view returns (address) {
		return collections[_id].teacher;
	}

	function getHashOf(bytes32 _id, address _participantAddress) public view returns (bytes32) {
		return collections[_id].hash[_participantAddress];
	}

	function getLearningHours(bytes32 _id) public view returns (uint256) {
		return collections[_id].learningHours;
	}

	function getGyan(bytes32 _id) public view returns (uint256) {
		return (collections[_id].academicGyan + collections[_id].nonAcademicGyan);
	}

	function getAcademicGyan(bytes32 _id) public view returns (uint256) {
		return collections[_id].academicGyan;
	}

	function getNonAcademicGyan(bytes32 _id) public view returns (uint256) {
		return collections[_id].nonAcademicGyan;
	}

	function getType(bytes32 _id) public view returns (bytes32) {
		return collections[_id]._type;
	}

	function getParticipants(bytes32 _id) public view returns (address[]) {
		return collections[_id].participantIndex;
	}

	function getResultOf(bytes32 _id, address _participantAddress) public view returns (uint256, uint256, uint256) {
		return (collections[_id].results['academic'][_participantAddress], collections[_id].results['engagement'][_participantAddress], collections[_id].results['commitment'][_participantAddress]);
	}

	function getAssessmentValueOf(bytes32 _id, bytes32 _assessmentRule) public view returns (uint256) {
		return collections[_id].assessmentRules[_assessmentRule];
	}

	function join(bytes32 _id, address _participantAddress, bytes32 _scholarshipId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(collections[_id].timestamp != 0);
		require(_participantAddress != address(0));
		// Make sure this participant does not already exist for this collection
		require(collections[_id].participants[_participantAddress] == 0);

		if (_scholarshipId == 'NA') {
			// Burn from student wallet
			require(karmaCoin.balanceOf(_participantAddress) >= getKarmaToBurn(collections[_id].academicGyan + collections[_id].nonAcademicGyan));
			karmaCoin.burnFrom(_participantAddress, getKarmaToBurn(collections[_id].academicGyan + collections[_id].nonAcademicGyan));
		} else {
			require(scholarshipContract.getTimestamp(_scholarshipId) != 0);
			require(scholarshipContract.getType(_scholarshipId) == 0x7075626c69630000000000000000000000000000000000000000000000000000);   // check if scholarship is public
			require(scholarshipContract.getParticipant(_scholarshipId, _participantAddress) != 0);
			require(karmaCoin.balanceOf(scholarshipContract.getWalletAddress(_scholarshipId)) >= getKarmaToBurn(collections[_id].academicGyan + collections[_id].nonAcademicGyan)); // this scholarship has enough karma balance
			// Burn from scholarship wallet
			karmaCoin.burnFrom(scholarshipContract.getWalletAddress(_scholarshipId), getKarmaToBurn(collections[_id].academicGyan + collections[_id].nonAcademicGyan));
		}
		collections[_id].participants[_participantAddress] = now;
		collections[_id].participantIndex.push(_participantAddress);
		CollectionJoin(_id, _participantAddress, msg.sender);
		return true;
	}

	function drop(bytes32 _id, address _participantAddress) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(collections[_id].timestamp != 0);
		require(_participantAddress != address(0));
		// Verify that the participant has not been assessed yet. Participants cannot drop after they have been assessed.
		require(collections[_id].results['academic'][_participantAddress] == 0);
		require(collections[_id].droppedParticipants[_participantAddress] == 0);

		collections[_id].droppedParticipants[_participantAddress] = now;
		CollectionDrop(_id, _participantAddress, msg.sender);
		return true;
	}

	function assess(bytes32 _id, address _participantAddress, bytes32 _assessmentRule, uint256 _engagementPercent, uint256 _commitmentPercent, bytes32 _hash) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(collections[_id].timestamp != 0);
		require(_participantAddress != address(0));
		require(collections[_id].hash[_participantAddress] == 0); // the hash for this collection has not been saved before
		require(collections[_id].assessmentRules[_assessmentRule] > 0);
		// Verify the participant being assessed has not been dropped previously.
		require(collections[_id].droppedParticipants[_participantAddress] == 0);
		// Verify the participant was not assessed previously
		require(collections[_id].results['academic'][_participantAddress] == 0);

		// Save the hash for this participant
		collections[_id].hash[_participantAddress] = _hash;

		// Add Gyan to participant and teacher wallets on assessment
		uint256 assessedAcademicGyan = getAssessedAcademicGyan(collections[_id].academicGyan, collections[_id].assessmentRules[_assessmentRule]);
		uint256 assessedEngagementGyan = getAssessedEngagementGyan(collections[_id].nonAcademicGyan, collections[_id].engagementRule, _engagementPercent);
		uint256 assessedCommitmentGyan = getAssessedCommitmentGyan(collections[_id].nonAcademicGyan, collections[_id].commitmentRule, _commitmentPercent);
		uint256 totalGyanEarned = assessedAcademicGyan + assessedEngagementGyan + assessedCommitmentGyan;
		gyanCoin.mintFor(_participantAddress, totalGyanEarned);
		gyanCoin.mintFor(collections[_id].teacher, totalGyanEarned);
		collections[_id].results['academic'][_participantAddress] = collections[_id].assessmentRules[_assessmentRule];
		collections[_id].results['engagement'][_participantAddress] = _engagementPercent;
		collections[_id].results['commitment'][_participantAddress] = _commitmentPercent;
		CollectionAssess(_id, _participantAddress, _assessmentRule, assessedAcademicGyan, assessedEngagementGyan, assessedCommitmentGyan, msg.sender);
		return true;
	}

	// Pure functions

	function getKarmaToBurn(uint256 _gyan) public view returns (uint256) {
		//TODO : put logic here to dynamically calculate Karma value based on gyan
		uint256 dailyKarmaMint = (karmaCoin.totalSupply().mul(5).div(100)).div(365);
		uint256 dailyGyanEarn = gyanCoin.yesterdayMint();
		return _gyan.mul(dailyKarmaMint.div(dailyGyanEarn));
	}

	function getAssessedAcademicGyan(uint256 _totalAcademicGyan, uint256 _percentGyan) pure returns (uint256) {
		return (_totalAcademicGyan.mul(_percentGyan)).div(100);
	}

	function getAssessedEngagementGyan(uint256 _totalNonAcademicGyan, uint256 _engagementRule, uint256 _percentGyan) pure returns (uint256) {
		return (_totalNonAcademicGyan.mul(_engagementRule).div(100).mul(_percentGyan)).div(100);
	}

	function getAssessedCommitmentGyan(uint256 _totalNonAcademicGyan, uint256 _commitmentRule, uint256 _percentGyan) pure returns (uint256) {
		return (_totalNonAcademicGyan.mul(_commitmentRule).div(100).mul(_percentGyan)).div(100);
	}

}
