pragma solidity 0.8.18;
// SPDX-License-Identifier: AGPL-3.0-or-later

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract dummycoin is ERC20 {
    constructor() ERC20("Dummy", "DUMB") {}

    function getmooni() external{
        _mint(msg.sender,1000000000000000000000);
    }
}