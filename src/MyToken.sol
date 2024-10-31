// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface TokenReceiver {
    function ReceiverApproval(address _from, uint256 _value, address _token, bytes calldata _exterData) external;
}

contract Mytoken {
    uint8 public decimals = 18;
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);

    constructor(uint256 initialSupply, string memory _name, string memory _symbol) {
        totalSupply = initialSupply * 10 ** uint8(decimals);
        name = _name;
        symbol = _symbol;
        balanceOf[msg.sender] = totalSupply;
    }

    function _Transfer(address _from, address _to, uint256 _amount) internal {
        require(_to != address(0));
        require(balanceOf[_from] > _amount);
        require(balanceOf[_from] + _amount > balanceOf[_from]);
        uint256 previousBalance = balanceOf[_from] + _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        assert(previousBalance == balanceOf[_from] + _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        _Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value < allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _Transfer(_from, _to, _value);
        return true;
    }

    function apporval(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function ApprovalAndCall(address _spender, uint256 _value, bytes memory _extData) public returns (bool success) {
        TokenReceiver Spender = TokenReceiver(_spender);
        if (apporval(_spender, _value)) {
            Spender.ReceiverApproval(msg.sender, _value, address(this), _extData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] > _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] > _value);
        require(_value < allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}
