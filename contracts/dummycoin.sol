pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract dummycoin is ERC20 {
    constructor() ERC20("Dummy", "DUMB") {}

    function getmooni() external{
        _mint(msg.sender,1000);
    }
}