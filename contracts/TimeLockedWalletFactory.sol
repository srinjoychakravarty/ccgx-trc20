pragma solidity ^0.4.23;

import "./TimeLockedWallet.sol";

contract TimeLockedWalletFactory {
    using SafeMaths for uint256;
    
    uint256 public _unlockDate = now.add(259200);   //sets unlock date in unix epoch to 3 days or 259200 seconds in the future
    mapping(address => address[]) wallets;

    function getWallets(address _user) public view returns(address[])
    {
        return wallets[_user];
    }

    function newTimeLockedWallet(address _owner) payable public returns(address wallet)
    {
        wallet = new TimeLockedWallet(msg.sender, _owner, _unlockDate);         // Creates new wallet.
        wallets[msg.sender].push(wallet);                                       // Adds wallet to sender's wallets.
        if(msg.sender != _owner)
        {
            wallets[_owner].push(wallet);                                       // If owner is not the same as sender then adds wallet to owner's wallets too.
        }
        wallet.transfer(msg.value);                                             // Send sun from this transaction to the created contract.
        emit Created(wallet, msg.sender, _owner, now, _unlockDate, msg.value);  // Emits event.
    }

    function () public
    {
        revert();                                                               // Prevents accidental sending of sun to the factory
    }

    event Created(address wallet, address from, address to, uint256 createdAt, uint256 unlockDate, uint256 amount);   //Emits Created event to Event Server
}
