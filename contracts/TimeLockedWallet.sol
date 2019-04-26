pragma solidity ^0.4.23;

import "./CCGX.sol";

contract TimeLockedWallet {
    address public creator;                                                     // creator address state variable
    address public owner;                                                       // owner address state variable
    uint256 public unlockDate;                                                  // specfied unlockDate state variable in unix epoch seconds
    uint256 public createdAt;                                                   // creation timestamp state variable

    modifier onlyOwner
    {
        require(msg.sender == owner);                                           // modifier checks if function was called by owner or else exits right away
        _;
    }

    constructor(address _creator, address _owner, uint256 _unlockDate) public
    {
      creator = _creator;                                                       // instantiates new TimeLockedWallet object with the one calling the function as creator
      owner = _owner;                                                           // instantiates new TimeLockedWallet object with specified owner
      unlockDate = _unlockDate;                                                 // instantiates new TimeLockedWallet object with specified frozen period upto a future unix epoch in seconds
      createdAt = now;                                                          // instantiates new TimeLockedWallet with a timestamp of current time
    }

    function() payable public {
        emit Received(msg.sender, msg.value);                                   // keeps all the sun sent to this address
    }

    function withdraw() onlyOwner public                                        // callable by owner only but only after specified 'freeze' time has passed
    {
       require(now >= unlockDate);                                              // ensures freeze date has passed
       msg.sender.transfer(address(this).balance);                              // now releases the frozen balance
       emit WithdrewTRX(msg.sender, address(this).balance);                     // triggers WithdrewTRX event
    }

    function withdrawTokens(address _tokenContract) onlyOwner public            // callable by owner only but after specified time for TRC20s like CCGX
    {
       require(now >= unlockDate);                                              // ensures freeze date has passed
       CCGX token = CCGX(_tokenContract);                                       // instantiates CCGX TRC20 object
       uint256 tokenBalance = token.balanceOf(this);                            // checks token balance of CCGX TRC20 frozen
       token.transfer(owner, tokenBalance);                                     // now releaases the frozen CCGX TRC20 token balance
       emit WithdrewTRC20Token(_tokenContract, msg.sender, tokenBalance);       // triggers WithdrewTRC20Token event
    }

    function info() public view returns(address, address, uint256, uint256, uint256)
    {
        return (creator, owner, unlockDate, createdAt, address(this).balance);  // returns complete suite of information for given TimeLockedWallet
    }

    event Received(address from, uint256 amount);                                //Emits Received Event to Event Server
    event WithdrewTRX(address to, uint256 amount);                               //Emits WithdrewTRX Event to Event Server
    event WithdrewTRC20Token(address tokenContract, address to, uint256 amount); //Emits WithdrewTRC20Token Event to Event Server
}
