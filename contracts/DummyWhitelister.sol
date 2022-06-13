
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// Fake whitelister representing an external protocol, whitelisted by Temple, that mints its own 1155 through RelicItems.sol

interface IRelicItems{
    function whitelistUser(address _userAddress, uint256 _itemId) external;
     function partnerMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

contract DummyWhitelister is Ownable {
    IRelicItems private RELICITEMS;

    // for testing
    function whitelist(address _userToWhitelist, uint256 _itemId) external {
        RELICITEMS.whitelistUser(_userToWhitelist, _itemId);
    }

    // fake protocol users would go through here to mint their POAPs
     function mintItem(uint256 _itemId, address _to) external {
        RELICITEMS.partnerMint(_to,_itemId,1,"");
    }

    function setRelicItems(address _relicItems) external onlyOwner {
        RELICITEMS = IRelicItems(_relicItems);
    }

}