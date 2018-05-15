pragma solidity ^0.4.23;

import "./CollectionBasic.sol";
import "../KarmaCoin.sol";
import "../GyanCoin.sol";

/**
 * @title BaseCollection
 * @author Aakash Bansal @ Peerbuds Inc.
 * @dev Basic version of collection contract
 * @dev Handled collection create, joining and assessment
 */
contract BaseCollection is CollectionBasic {

	using SafeMath for uint256;

	KarmaCoin public karmaCoin;
	GyanCoin public gyanCoin;

	struct Collection {
		bytes32 hash;
		bytes32 _type;
		uint256 academicGyan;
		uint256 nonAcademicGyan;
		address teacher;
		uint256 timestamp;
		mapping(address => uint256) participants;
		address[] participantIndex;
		mapping(bytes32 => uint256) assessmentRules;
		bytes32[] assessmentRuleKeys;
		uint256[] assessmentRuleValues;
		mapping(address => bytes32) results;
	}

	mapping(bytes32 => Collection) collections;

	function BaseCollection(KarmaCoin _karma, GyanCoin _gyan) {
		require(_karma != address(0));
		require(_gyan != address(0));

		karmaCoin = _karma;
		gyanCoin = _gyan;
	}

	function create(bytes32 _id, address _teacherAddress, bytes32 _type, bytes32 _hash, uint256 _academicGyan, uint256 _nonAcademicGyan, bytes32[] _assessmentRuleKeys, uint256[] _assessmentRuleValues) public returns (bool) {
		require(_id[0] != 0);
		require(_teacherAddress != address(0));
		require(_type[0] != 0);
		require(_hash[0] != 0);
		require(_academicGyan > 0);
		require(_nonAcademicGyan > 0);
		require(_assessmentRuleKeys.length == _assessmentRuleValues.length);

		collections[_id].teacher = _teacherAddress;
		collections[_id].hash = _hash;
		collections[_id]._type = _type;
		collections[_id].academicGyan = _academicGyan;
		collections[_id].nonAcademicGyan = _nonAcademicGyan;
		collections[_id].timestamp = now;
		// Map _assessmentRules array to contract variables
		for (uint i = 0; i < _assessmentRuleKeys.length; i++) {
			collections[_id].assessmentRules[_assessmentRuleKeys[i]] = _assessmentRuleValues[i];
			collections[_id].assessmentRuleKeys.push(_assessmentRuleKeys[i]);
		}
		return true;
	}

	function getData(bytes32 _id) public view returns (bytes32, bytes32, bytes32[], uint256, uint256, address, uint256) {
		// Solidity does not yet support returning structs to web3
		return (collections[_id]._type, collections[_id].hash, collections[_id].assessmentRuleKeys, collections[_id].academicGyan, collections[_id].nonAcademicGyan , collections[_id].teacher, collections[_id].timestamp);
	}

	function getTeacher(bytes32 _id) public view returns (address) {
		return collections[_id].teacher;
	}

	function getHash(bytes32 _id) public view returns (bytes32) {
		return collections[_id].hash;
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

	function getResultOf(bytes32 _id, address _participantAddress) public view returns (bytes32) {
		return collections[_id].results[_participantAddress];
	}

	function getAssessmentValueOf(bytes32 _id, bytes32 _assessmentRule) public view returns (uint256) {
		return collections[_id].assessmentRules[_assessmentRule];
	}

	function join(bytes32 _id, address _participantAddress, address _burnAddress) public returns (bool) {
		require(_id[0] != 0);
		require(_participantAddress != address(0));
		require(_burnAddress != address(0));
		// Make sure this participant does not already exist for this collection
		require(collections[_id].participants[_participantAddress] == 0);

		karmaCoin.burnFrom(_burnAddress, getKarmaToBurn(collections[_id].academicGyan + collections[_id].nonAcademicGyan));
		collections[_id].participants[_participantAddress] = now;
		collections[_id].participantIndex.push(_participantAddress);
		return true;
	}

	function assess(bytes32 _id, address _participantAddress, bytes32 _assessmentRule) public returns (bool) {
		require(_id[0] != 0);
		require(_participantAddress != address(0));
		require(collections[_id].assessmentRules[_assessmentRule] > 0);

		// Add Gyan to participant and teacher wallets on assessment
		uint256 assessedAcademicGyan = getAssessedAcademicGyan(collections[_id].academicGyan, collections[_id].assessmentRules[_assessmentRule]);
		gyanCoin.mintFor(_participantAddress, assessedAcademicGyan + collections[_id].nonAcademicGyan);
		gyanCoin.mintFor(collections[_id].teacher, assessedAcademicGyan + collections[_id].nonAcademicGyan);
		collections[_id].results[_participantAddress] = _assessmentRule;
		return true;
	}

	// Pure functions

	function getKarmaToBurn(uint256 _gyan) pure returns (uint256) {
		//TODO : put logic here to dynamically calculate Karma value based on gyan
		return _gyan;
	}

	function getAssessedAcademicGyan(uint256 _totalAcademicGyan, uint256 _percentGyan) pure returns (uint256) {
		return (_totalAcademicGyan.mul(_percentGyan)).div(100);
	}

}