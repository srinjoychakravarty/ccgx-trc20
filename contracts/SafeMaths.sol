pragma solidity ^0.4.23;

//Maths operations with safety checks that throw on error
library SafeMaths {

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
