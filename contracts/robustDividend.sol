pragma solidity ^0.4.23;

contract RobustDividendToken {

    uint256 public scaledRemainder = 0;
    uint256 public scaling = uint256(10) ** 8;
    uint256 public scaledDividendPerToken;
    mapping(address => uint256) public scaledDividendBalanceOf;
    mapping(address => uint256) public scaledDividendCreditedTo;
    mapping(address => mapping(address => uint256)) public allowance;

    // string public name = "Robust Dividend Token";
    // string public symbol = "DIV";
    // uint8 public decimals = 18;
    // uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);
    // mapping(address => uint256) public balanceOf;
    //event Transfer(address indexed from, address indexed to, uint256 value);
    // event Approval(address indexed owner, address indexed spender, uint256 value);
    //
    // function approve(address spender, uint256 value) public returns (bool success)
    // {
    //     allowance[msg.sender][spender] = value;
    //     emit Approval(msg.sender, spender, value);
    //     return true;
    // }
    // function RobustDividendToken() public
    // {
    //     balanceOf[msg.sender] = totalSupply;
    //     emit Transfer(address(0), msg.sender, totalSupply);
    // }

    function update(address account) internal
    {
        uint256 owed = scaledDividendPerToken - scaledDividendCreditedTo[account];
        scaledDividendBalanceOf[account] += balanceOf[account] * owed;
        scaledDividendCreditedTo[account] = scaledDividendPerToken;
    }

    function transfer(address to, uint256 value) public returns (bool success)
    {
        require(balanceOf[msg.sender] >= value);
        update(msg.sender);                                                     // <-- added to simple CCGX TRC20 contract
        update(to);                                                             // <-- added to simple CCGX TRC20 contract
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success)
    {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);
        update(from);                                                           // <-- added to simple CCGX TRC20 contract
        update(to);                                                             // <-- added to simple CCGX TRC20 contract
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function deposit() public payable
    {
        uint256 available = (msg.value * scaling) + scaledRemainder;            // scales the deposit and add the previous remainder
        scaledDividendPerToken += available / totalSupply;
        scaledRemainder = available % totalSupply;                              // computes the new remainder
    }

    function withdraw() public
    {
        update(msg.sender);
        uint256 amount = scaledDividendBalanceOf[msg.sender] / scaling;
        scaledDividendBalanceOf[msg.sender] %= scaling;                         // retains the remainder
        msg.sender.transfer(amount);
    }
}
