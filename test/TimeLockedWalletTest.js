const TimeLockedWallet = artifacts.require("./TimeLockedWallet.sol");
const CCGX = artifacts.require("./CCGX.sol");
let ethToSend = web3.utils.toWei('1', 'milliether');
let someGas = web3.utils.toWei('1', 'finney');
let creator;
let owner;

contract('TimeLockedWallet', (accounts) =>
{
    before(async () =>
    {
        creator = accounts[0];                                                  //first tronbox sample address
        owner = accounts[1];                                                    //second tronbox sample address
        other = accounts[2];                                                    //third tronbox sample address
        futureTime = Math.floor((new Date).getTime() / 1000) + 50000;           //50,000 seconds into the future
    });

    it("Owner can withdraw the funds after the unlock date", async () =>
    {
        let now = Math.floor((new Date).getTime() / 1000);                      //sets unlock date in unix epoch to now
        let timeLockedWallet = await TimeLockedWallet.new(creator, owner, now); //create the contract and load the contract with some sun
        await timeLockedWallet.send(ethToSend, {from: creator});
        assert(ethToSend == await web3.eth.getBalance(timeLockedWallet.address));
        let balanceBefore = await web3.eth.getBalance(owner);
        await timeLockedWallet.withdraw({from: owner});
        let balanceAfter = await web3.eth.getBalance(owner);
        assert(balanceAfter - balanceBefore >= ethToSend - someGas);
    });

    it("Nobody can withdraw the funds before the unlock date", async () =>
    {
        let timeLockedWallet = await TimeLockedWallet.new(creator, owner, futureTime);  //creates the contract
        await timeLockedWallet.send(ethToSend, {from: creator});                        //load the contract with some sun
        assert(ethToSend == await web3.eth.getBalance(timeLockedWallet.address));
        try
        {
            await timeLockedWallet.withdraw({from: owner})
            assert(false, "Expected error not received");
        }
        catch (error) {}                                                               //expected
        try
        {
            await timeLockedWallet.withdraw({from: creator})
            assert(false, "Expected error not received");
        }
        catch (error) {}                                                              //expected
        try
        {
            await timeLockedWallet.withdraw({from: other})
            assert(false, "Expected error not received");
        }
        catch (error) {}                                                              //expected
        assert(ethToSend == await web3.eth.getBalance(timeLockedWallet.address));     //contract balance is intact
    });

    it("Nobody other than the owner can withdraw funds after the unlock date", async () =>
    {
        let now = Math.floor((new Date).getTime() / 1000);                            //sets unlock date in unix epoch to now
        let timeLockedWallet = await TimeLockedWallet.new(creator, owner, now);       //creates the freeze contract
        await timeLockedWallet.send(ethToSend, {from: creator});                      //loads the contract with some test sun
        assert(ethToSend == await web3.eth.getBalance(timeLockedWallet.address));
        let balanceBefore = await web3.eth.getBalance(owner);
        try
        {
          await timeLockedWallet.withdraw({from: creator})
          assert(false, "Expected error not received");
        }
        catch (error) {}                                                              //expected
        try
        {
          await timeLockedWallet.withdraw({from: other})
          assert(false, "Expected error not received");
        }
        catch (error) {}                                                              //expected
        assert(ethToSend == await web3.eth.getBalance(timeLockedWallet.address));     //contract balance is intact
    });

    it("Owner can withdraw the CCGX TRC20 Token after the unlock date", async () => {
        let now = Math.floor((new Date).getTime() / 1000);                                      //sets unlock date in unix epoch to current time
        let timeLockedWallet = await TimeLockedWallet.new(creator, owner, now);                 //creates the TimeLockedWallet contract to freeze tokens in
        let ccgx = await CCGX.new();                                                            //initializes the CCGX TRC20 contract
        assert(42000000000000 == await ccgx.balanceOf(creator));                                //checks that the creator has total supply 42 million tokens (+ 6 decimals) after contract genesis
        let amountOfTokens = 1000000000;                                                        //sets aside 1000000000 CCGX TRC20 tokens to send
        await ccgx.transfer(timeLockedWallet.address, amountOfTokens, {from: creator});         //creator (aka ccgx contract owner) transfers 1000000000 CCGX TRC20 tokens to freeze in TimeLockedWallet
        assert(amountOfTokens == await ccgx.balanceOf(timeLockedWallet.address));               //checks that TimeLockedWallet has correct amount of CCGX TRC20 tokens
        await timeLockedWallet.withdrawTokens(ccgx.address, {from: owner});                     //owner of TimeLockedWallet (different from TimeLockedWallet creator) rightfully withdraws by unfreezing all tokens
        let balance = await ccgx.balanceOf(owner);                                              //owner's balance is stored for comparison
        assert(balance.toNumber() == amountOfTokens);                                           //checks to see if owner's balance matches the total amount unfrozen from the TimeLockedWallet
    });

    it("Allow getting info about the wallet", async () => {
        let now = Math.floor((new Date).getTime() / 1000);                                      // Remembers current time.
        let unlockDate = now + 100000;                                                          // Set unlockDate to future time.
        let timeLockedWallet = await TimeLockedWallet.new(creator, owner, unlockDate);          // Creates new LockedWallet.
        await timeLockedWallet.send(ethToSend, {from: creator});                                // Sends sun to the wallet.
        let info = await timeLockedWallet.info();                                               // Gets info about the wallet.
        assert(info[0] == creator);                                                             // Compares result with expected values.
        assert(info[1] == owner);
        assert(info[2].toNumber() == unlockDate);
        assert(info[3].toNumber() == now);
        assert(info[4].toNumber() == ethToSend );
    });
});
