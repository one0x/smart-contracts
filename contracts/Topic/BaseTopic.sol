pragma solidity ^0.4.23;
import "../ownership/rbac/RBAC.sol";
import "../ownership/PbOwnable.sol";

contract BaseTopic is PbOwnable, RBAC {

	mapping(bytes32 => bytes32) topics;
	bytes32[] topicArray;
	mapping(address => bytes32[]) userTopics;

	function BaseTopic(){

	}

	function addTopic(bytes32 topicId, bytes32 topicName) public onlyRole(ROLE_PARTNER) returns(bool) {
		topics[topicId] = topicName;
		return true;
	}
}
