pragma solidity ^0.5.0;

import "./KarmaCoin.sol";
import "./ownership/PbOwnable.sol";
import "./ownership/rbac/RBAC.sol";

contract ScholarshipContract is PbOwnable, RBAC {

	KarmaCoin public karmaCoin;

	struct Scholarship {
		uint256 prerequisite;
		uint256 transactionLimit;
		address owner;
		bytes32 _type;
		address walletAddress;
		bytes32 title;
		uint256 timestamp;
		bytes32 description;
		mapping(address => uint256) participants;
		address[] participantIndex;
		mapping(bytes32 => bool) allowedCollections;
		mapping(bytes32 => bool) allowedQuestions;
	}

	constructor(
		KarmaCoin _karma
	) public {
		karmaCoin = _karma;
	}

	event ScholarshipCreate(bytes32 _id, bytes32 _type, address pbNode);
	event ScholarshipJoin(bytes32 _id, address _participantAddress, address pbNode);
	event ScholarshipAddCollection(bytes32 _id, bytes32 _collectionId, address pbNode);
	event ScholarshipAddQuestion(bytes32 _id, bytes32 _questionId, address pbNode);
	event ScholarshipDrop(bytes32 _id, address _participantAddress, address pbNode);

	mapping(bytes32 => Scholarship) public scholarships;

	function create(bytes32 _id, address _ownerAddress, bytes32 _type, bytes32 _title, bytes32 _description, uint256 _prerequisite, uint256 _transactionLimit, address _walletAddress, bytes32[] memory _allowedCollections) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(_ownerAddress != address(0));
		require(_type[0] != 0);
		require(_title[0] != 0);
		require(_description[0] != 0);
		require(_transactionLimit > 0);
		require(_walletAddress != address(0));
		require(scholarships[_id].timestamp == 0);

		scholarships[_id].title = _title;
		scholarships[_id].prerequisite = _prerequisite;
		scholarships[_id].description = _description;
		scholarships[_id].owner = _ownerAddress;
		scholarships[_id]._type = _type;
		scholarships[_id].transactionLimit = _transactionLimit;
		scholarships[_id].walletAddress = _walletAddress;
		scholarships[_id].timestamp = now;
		// Map _assessmentRules array to contract variables
		for (uint8 i = 0; i < _allowedCollections.length; i++) {
			scholarships[_id].allowedCollections[_allowedCollections[i]] = true;
		}
		emit ScholarshipCreate(_id, _type, msg.sender);
		return true;
	}

	function getWalletAddress(bytes32 _id) public view returns (address) {
		return scholarships[_id].walletAddress;
	}

	function join(bytes32 _id, address _participantAddress) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(scholarships[_id].timestamp != 0);
		require(_participantAddress != address(0));
		// Make sure this participant does not already exist for this scholarship
		require(scholarships[_id].participants[_participantAddress] == 0);

		scholarships[_id].participants[_participantAddress] = now;
		scholarships[_id].participantIndex.push(_participantAddress);
		emit ScholarshipJoin(_id, _participantAddress, msg.sender);
		return true;
	}

	function addCollection(bytes32 _id, bytes32 _collectionId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(_collectionId[0] != 0);
		require(scholarships[_id].timestamp != 0);
		require(scholarships[_id].allowedCollections[_collectionId] == false);

		scholarships[_id].allowedCollections[_collectionId] = true;
		emit ScholarshipAddCollection(_id, _collectionId, msg.sender);
		return true;
	}

	function addQuestion(bytes32 _id, bytes32 _questionId) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(_questionId[0] != 0);
		require(scholarships[_id].timestamp != 0);  // scholarship exists
		require(scholarships[_id].allowedQuestions[_questionId] == false);  // question does not already exist.

		scholarships[_id].allowedQuestions[_questionId] = true;
		emit ScholarshipAddQuestion(_id, _questionId, msg.sender);
		return true;
	}

	function getAllowedCollection(bytes32 _id, bytes32 _collectionId) public view returns (bool) {
		require(_id[0] != 0);
		require(_collectionId[0] != 0);
		return scholarships[_id].allowedCollections[_collectionId];
	}

	function getAllowedQuestion(bytes32 _id, bytes32 _questionId) public view returns (bool) {
		require(_id[0] != 0);
		require(_questionId[0] != 0);
		return scholarships[_id].allowedQuestions[_questionId];
	}

	function drop(bytes32 _id, address _participantAddress) public onlyRole(ROLE_PARTNER) returns (bool) {
		require(_id[0] != 0);
		require(scholarships[_id].timestamp != 0);
		require(_participantAddress != address(0));
		require(scholarships[_id].participants[_participantAddress] != 0);

		delete scholarships[_id].participants[_participantAddress];
		emit ScholarshipDrop(_id, _participantAddress, msg.sender);
		return true;
	}

	function getScholarshipData(bytes32 _id) public view returns (bytes32, bytes32, bytes32, address, address, uint256) {
		require(_id[0] != 0);
		return (scholarships[_id].title, scholarships[_id]._type, scholarships[_id].description, scholarships[_id].walletAddress, scholarships[_id].owner, scholarships[_id].timestamp);
	}

	function getTimestamp(bytes32 _id) public view returns (uint256) {
		return scholarships[_id].timestamp;
	}

	function getParticipant(bytes32 _id, address _participantAddress) public view returns (uint256) {
		return scholarships[_id].participants[_participantAddress];
	}

	function getType(bytes32 _id) public view returns (bytes32) {
		return scholarships[_id]._type;
	}

	function balanceOf(bytes32 _id) public view returns (uint256) {
		require(_id[0] != 0);
		return karmaCoin.balanceOf(scholarships[_id].walletAddress);
	}

	modifier hasScholarship(bytes32 _id, address _participantAddress) {
		require(scholarships[_id].participants[_participantAddress] != 0);
		_;
	}

}
