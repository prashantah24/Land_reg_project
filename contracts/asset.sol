pragma solidity ^0.5.0;

contract asset { 

    address public creatorAdmin;
	enum PropStatus { NotExist, Pending, Approved, Rejected }

	struct PropertyDetail {
		PropStatus status;
		uint value;
		address currOwner;
	}

	// Dictionary of all the properties, mapped using their { propertyId: PropertyDetail } pair.
	mapping(uint => PropertyDetail) public properties;
	mapping(uint => address) public propOwnerChange;

    mapping(address => int) public users;
    mapping(address => bool) public verifiedUsers;

	modifier onlyOwner(uint _propId) {
		require(properties[_propId].currOwner == msg.sender);
		_;
	}

	modifier verifiedUser(address _user) {
	    require(verifiedUsers[_user]);
	    _;
	}

	modifier verifiedAdmin() {
		require(users[msg.sender] >= 2 && verifiedUsers[msg.sender]);
		_;
	}

	modifier verifiedSuperAdmin() {
	    require(users[msg.sender] == 3 && verifiedUsers[msg.sender]);
	    _;
	}

	// Initializing the User Contract.
	constructor() public {
		creatorAdmin = msg.sender;
		users[creatorAdmin] = 3;
		verifiedUsers[creatorAdmin] = true;
	}

	// Create a new Property.
	function createProperty(uint _propId, uint _value, address _owner) public verifiedAdmin verifiedUser(_owner) returns (bool) {
		properties[_propId] = PropertyDetail(PropStatus.Pending, _value, _owner);
		return true;
	}

	// Approve the new Property.
	function approveProperty(uint _propId) public verifiedSuperAdmin returns (bool){
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = PropStatus.Approved;
		return true;
	}

	// Reject the new Property.
	function rejectProperty(uint _propId) public verifiedSuperAdmin returns (bool){
		require(properties[_propId].currOwner != msg.sender);
		properties[_propId].status = PropStatus.Rejected;
		return true;
	}

	// Request Change of Ownership.
	function changeOwnership(uint _propId, address _newOwner) public onlyOwner(_propId) verifiedUser(_newOwner) returns (bool) {
		require(properties[_propId].currOwner != _newOwner);
		require(propOwnerChange[_propId] == address(0));
		propOwnerChange[_propId] = _newOwner;
		return true;
	}

	// Approve chage in Onwership.
	function approveChangeOwnership(uint _propId) public verifiedSuperAdmin returns (bool) {
	    require(propOwnerChange[_propId] != address(0));
	    properties[_propId].currOwner = propOwnerChange[_propId];
	    propOwnerChange[_propId] = address(0);
	    return true;
	}

	// Change the price of the property.
    function changeValue(uint _propId, uint _newValue) onlyOwner(_propId) public returns (bool) {
        require(propOwnerChange[_propId] == address(0));
        properties[_propId].value = _newValue;
        return true;
    }

	// Get the property details.
	function getPropertyDetails(uint _propId) public view returns (PropStatus, uint, address) {
		return (properties[_propId].status, properties[_propId].value, properties[_propId].currOwner);
	}

	// Add new user.
	function addNewUser(address _newUser) public verifiedAdmin returns (bool) {
	    require(users[_newUser] == 0);
	    require(verifiedUsers[_newUser] == false);
	    users[_newUser] = 1;
	    return true;
	}

	// Add new Admin.
	function addNewAdmin(address _newAdmin) public verifiedSuperAdmin returns (bool) {
	    require(users[_newAdmin] == 0);
	    require(verifiedUsers[_newAdmin] == false);
	    users[_newAdmin] = 2;
	    return true;
	}

	// Add new SuperAdmin.
	function addNewSuperAdmin(address _newSuperAdmin) public verifiedSuperAdmin returns (bool) {
	    require(users[_newSuperAdmin] == 0);
	    require(verifiedUsers[_newSuperAdmin] == false);
	    users[_newSuperAdmin] = 3;
	    return true;
	}

	// Approve User.
	function approveUsers(address _newUser) public verifiedSuperAdmin returns (bool) {
	    require(users[_newUser] != 0);
	    verifiedUsers[_newUser] = true;
	    return true;
	}
}