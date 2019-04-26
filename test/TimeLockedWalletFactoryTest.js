const TimeLockedWallet = artifacts.require("./TimeLockedWallet.sol");
const TimeLockedWalletFactory = artifacts.require("./TimeLockedWalletFactory.sol");

let ethToSend = web3.utils.toWei('1', 'ether');
let someGas = web3.utils.toWei('0.01', 'ether');

let timeLockedWalletFactory;
let creator;
let owner;
let timeLockedWalletAbi;

contract('TimeLockedWalletFactory', (accounts) =>
{
    before(async () =>
    {
        creator = accounts[0];
        owner = accounts[1];
        timeLockedWalletFactory = await TimeLockedWalletFactory.new({from: creator});
    });

    it("Factory created contract is working well", async () =>
    {
        let now = Math.floor((new Date).getTime() / 1000);                            // Creates the wallet contract.
        await timeLockedWalletFactory.newTimeLockedWallet(owner);
        let creatorWallets = await timeLockedWalletFactory.getWallets.call(creator);  // Checks if wallet can be found in creator's wallets.
        assert(1 == creatorWallets.length);
        let ownerWallets = await timeLockedWalletFactory.getWallets.call(owner);      // Checks if wallet can be found in owners's wallets.
        assert(1 == ownerWallets.length);
        assert(creatorWallets[0] === ownerWallets[0]);                                // Checks if this is the same wallet for both of them.
    });
});
