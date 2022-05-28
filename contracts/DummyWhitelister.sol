
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRelicItems{
    function whitelistUser(address _userAddress, uint256 _itemId) external;
}

contract DummyWhitelister is Ownable {
    IRelicItems private RELICITEMS;

    function whitelist(address _userToWhitelist, uint256 _itemId) external {
        RELICITEMS.whitelistUser(_userToWhitelist, _itemId);
    }

    function setRelicItems(address _relicItems) external onlyOwner {
        RELICITEMS = IRelicItems(_relicItems);
    }



}