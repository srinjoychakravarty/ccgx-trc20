pragma solidity ^0.4.23;
//pragma experimental ABIEncoderV2;

// SafeMath operations with safety checks that revert on error
library SafeMath {

    //Multiplies two numbers, reverts on overflow with gas optimization
    //by requiring 'a' not being zero and hence not testing 'b'.
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if (a == 0)
        {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    //Integer division of two numbers truncating the quotient, reverts on division by zero.
    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    //Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    //Adds two numbers, reverts on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    //Divides two numbers and returns the remainder (unsigned integer modulo), reverts when dividing by zero.
    function mod(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b != 0);
        return a % b;
    }

    //Safe way to detect overflow in exponentiation.
    function exp(int256 a, uint256 pow) internal pure returns (int256)
    {
       assert(a >= 0);
       int256 result = 0;
       if (a == 0)
       {
          require(pow > 0, "Exponentiating 0 to 0 is not defined.");
          return result;
       }
       else
       {
          result = 1;
          for (uint256 i = 0; i < pow; i++)
          {
             result *= a;
             assert(result >= a);
          }
          return result;
       }
    }
}

contract CCGX {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeMath for int256;

    string public name;                                                         // Fully qualified nane of the token
    string public symbol;                                                       // Ticker of token on Exchanges
    uint256 private totalSupply;                                                // Includes 6 decimals as 10^6 sun = 1 TRX
    mapping (address => uint256) public balanceOf;                              // This creates an array with all balances

    // key-value pair of custodian struct
    struct Custodian {
      uint256 maxSpend;
      uint256 maxBurn;
    }

    //maps max send and burn allowances for each approved custodian
    mapping (address => mapping (address => Custodian)) public allowance;

    //Struct that tracks amounts controlled by beneficiary for a given benefactor address
    struct Pip {
      bool exists;
      address inheritor;
      uint256 inheritedSpend;
      uint256 inheritedBurn;
    }

    //Each benefactor address like miss havisham's corresponds to an array of beneficiaries each consisting of a lucky boy like Pip
    mapping (address => Pip[]) missHavisham;

    //Each benefactor address is also maintained in an auxiliary benefactorKeys array for cheap gas accounting
    address[] public benefactorKeys;

    // The following generate transfer, approval and burn events respectively on the tron blockchain that notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event SpendApproval(address indexed _owner, address indexed _spender, uint256 _value);
    event BurnApproval(address indexed _owner, address indexed _arsonist, uint256 _value);

    uint256 public initialSupply = 42000000;
    string tokenName = 'CryptoCannabisGame';
    string tokenSymbol = 'CCGX';
    uint8 public decimals = 6;

    //Constructor function initializes contract with initial supply tokens to the creator of the contract
    constructor() public
    {
        // Multiplies total supply with the decimal precision through safe exponentiation
        totalSupply = uint256((int256(initialSupply))).mul(uint256(int256(10).exp(decimals)));
        balanceOf[msg.sender] = totalSupply;                                    // Gives the contract creator all initial tokens
        name = tokenName;                                                       // Sets the name for display purposes
        symbol = tokenSymbol;                                                   // Sets the symbol for display purposes
    }

    //Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        require(_to != address(0x0));                                           // Prevents accidental transfer to 0x0 address.
        require(balanceOf[_from] >= _value);                                    // Ensures the sender does not transfer more than he has
        require(balanceOf[_to].add(_value) >= balanceOf[_to]);                  // Checks for overflows
        uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);        // Save this for the assertion in the last line of this function
        balanceOf[_from] = balanceOf[_from].sub(_value);                        // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                            // Add the same to the recipient
        emit Transfer(_from, _to, _value);                                      // Emits the Transfer event defined above
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);       // Asserts that no tokens are created or destroyed in the ecosystem
    }

    //Transfers tokens of _value` amount `_to` the address of the recipient from caller's account
    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //Destroy `_value` amount of tokens from the Tron blockchain irreversibly
    function burn(uint256 _value) public returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);                               // Checks that the arsonist isn't burning more than they own
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);              // Subtracts from the sender first
        totalSupply = totalSupply.sub(_value);                                  // Subtracts from the totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    //Sets allowance for the authorized '_spender' address to spend a maximum of `_spend` tokens on your behalf
    function approveSpend(address _spender, uint256 _spend) public returns (bool success)
    {
        require(_spender != address(0));                                        //Address approved shouldn't be 0x0
        require(_spender != msg.sender);                                        //Do not waste gas to approve self
        require(balanceOf[msg.sender] >= _spend);                               //Address balance must be >= _spend of custody being given to
        allowance[msg.sender][_spender].maxSpend = _spend;                      //Precisely sets 'maxSpend' to '_spend' amount which may even lower the limit
        Pip memory beneficiary = Pip(true, _spender, _spend, 0);                //benefactor ('missHavisham') approves a beneficiary ('Pip')
        missHavisham[msg.sender].push(beneficiary );                            //benefactor ('missHavisham') appends to her beneficiary list
        benefactorKeys.push(msg.sender);                                        //user calling approveSpend has address added to benefactorKeys array
        emit SpendApproval(msg.sender, _spender, _spend);
        return true;
     }

   function addressToBytes(address a) internal pure returns (bytes memory b)             //efficiently converts tron address into printable 20 byte variable
   {
       assembly {
           let m := mload(0x40)
           a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
           mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
           mstore(0x40, add(m, 52))
           b := m
      }
   }

    function bytesToAddress(bytes memory b) internal pure returns (address)                 //converts input bytes into address
    {
        uint result = 0;
        for (uint i = b.length-1; i+1 > 0; i--)
        {
            uint c = uint(b[i]);
            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
            result += to_inc;
        }
        return address(result);
    }

    // Return array of bytes32 as solidity doesn't support returning string arrays yet
   function getApprovedSpenders (address _benefactor) public view returns (address[])
   {
     uint i;
     uint array_len = missHavisham[_benefactor].length;                                         //checks number of approved benefactors for a given address
     address[] memory spenders = new address[](array_len);                                      //creates fixed length array 'spenders' to fit number of beneficiaries
     for(i = 0; i < array_len; i++)
     {
       spenders[i] = bytesToAddress(addressToBytes(missHavisham[_benefactor][i].inheritor));    //for loop inserts each benefciary address as address into 'spenders' array
     }
     return spenders;
   }

    // function retrieveSpenders (address _benefactor) public view returns (address)
    // {
    //
    // }
    //
    // function retrieveArsonists (address _benefactor) public view returns (address)
    // {
    //
    // }
    //
    // function getTotalDelegatedSpend (address _benefactor) public view returns (address)
    // {
    //
    // }
    //
    // function getTotalDelegatedBurn (address _benefactor) public view returns (address)
    // {
    //
    // }

     //Sets allowance for the authorized '_arsonist' address to burn a maximum of `_burn` tokens on your behalf
     function approveBurn(address _arsonist, uint256 _burn) public returns (bool success)
     {
         require(_arsonist != address(0));                                        //Address approved shouldn't be 0x0
         require(_arsonist != msg.sender);                                        //Do not waste gas to provide burn approval to self
         require(balanceOf[msg.sender] >= _burn);                                //address balance must be >= amount of allowable _burn
         allowance[msg.sender][_arsonist].maxBurn = _burn;
         emit BurnApproval(msg.sender, _arsonist, _burn);
         return true;
     }

      // Increments the amount of tokens alloted by owner to be spent on their behalf by addedValue.
     function increaseSpendAllowance(address _spender, uint256 _addedValue) public returns (bool)
     {
        require(_spender != address(0));                                                                                      //Address approved shouldn't be 0x0
        require(_spender != msg.sender);                                                                                      //Do not waste gas to approve self
        require(balanceOf[msg.sender] >= allowance[msg.sender][_spender].maxSpend.add(_addedValue));                          //address balance must be >= total _value of custody given
        allowance[msg.sender][_spender].maxSpend = allowance[msg.sender][_spender].maxSpend.add(_addedValue);
        emit SpendApproval(msg.sender, _spender, allowance[msg.sender][_spender].maxSpend);
        return true;
     }

     // Increments the amount of tokens alloted by owner to be burned on their behalf by addedBurn.
     function increaseBurnAllowance(address _arsonist, uint256 _addedBurn) public returns (bool success)
     {
         require(_arsonist != address(0));                                                                                         //Address approved shouldn't be 0x0
         require(_arsonist != msg.sender);                                                                                         //Do not waste gas to provide burn approval to self
         require(balanceOf[msg.sender] >= allowance[msg.sender][_arsonist].maxBurn.add(_addedBurn));                               //address balance must be >= total allowable burn
         allowance[msg.sender][_arsonist].maxBurn = allowance[msg.sender][_arsonist].maxBurn.add(_addedBurn);
         emit BurnApproval(msg.sender, _arsonist, allowance[msg.sender][_arsonist].maxBurn);
         return true;
     }

   //Transfers tokens on on behalf of designated `_from` address of `_value` amount `_to` a chosen recipient address
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
   {
       require(_value <= allowance[_from][msg.sender].maxSpend);                                    // Ensures amount being transferred is in line with approved allowance
       allowance[_from][msg.sender].maxSpend = allowance[_from][msg.sender].maxSpend.sub(_value);   // Decrements spend allowance by the amount already transferred out
       _transfer(_from, _to, _value);                                                               // Triggers transfer
       return true;
   }

   //Destroy `_value` amount of tokens from the other account and the Tron blockchain irreversibly with the blessings of `_from`.
   function burnFrom(address _from, uint256 _value) public returns (bool success)
   {
       require(balanceOf[_from] >= _value);                                                       // Ensures amount being burned is lesser than or equal to current balance
       require(_value <= allowance[_from][msg.sender].maxBurn);                                   // Ensures amount being destroyed is in line with burn allowance
       balanceOf[_from] = balanceOf[_from].sub(_value);                                           // Subtract from the targeted balance
       allowance[_from][msg.sender].maxBurn = allowance[_from][msg.sender].maxBurn.sub(_value);   // Subtract from the sender's allowance
       totalSupply = totalSupply.sub(_value);                                                     // Update totalSupply
       emit Burn(_from, _value);
       return true;
   }
}
