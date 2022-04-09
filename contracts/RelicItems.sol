pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IRelic { 
    function getRelicId(address _owner) external view returns (uint256);
    function hasRelic(address _owner) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract RelicItems is
    ERC1155,
    Ownable,
    Pausable,
    ERC1155Burnable,
    ERC1155Supply,
    ReentrancyGuard
{
    constructor() ERC1155("") {}

    // @dev Partner Minting
    // @dev whitelisted partners
    mapping (address => bool) public whiteListedPartners;
    // @dev itemId for each partner
    mapping (address => uint256) public partnerId;

    // @dev Relic.sol
    IRelic private RELIC;

    //------- External -------//

    // @dev called from Relic when transfering items from Templar wallet into Relic
    function equipItems(uint256[] memory _itemIds, uint256[] memory _amounts) external {
        require(msg.sender==address(RELIC));

        _beforeTokenTransfer(msg.sender, msg.sender, address(RELIC), _itemIds, _amounts, "");

        // transfer to Relic
        _safeBatchTransferFrom(msg.sender, address(RELIC), _itemIds, _amounts, "");
    }

     // @dev called from Relic when transfering items from Relic into Templar wallet
    function unEquipItems(address _target, uint256[] memory _itemIds, uint256[] memory _amounts) external {
        require(msg.sender==address(RELIC));
        
        _beforeTokenTransfer(address(RELIC), address(RELIC), _target, _itemIds, _amounts, "");

        // transfer to target
        _safeBatchTransferFrom( address(RELIC), msg.sender, _itemIds, _amounts, "");
    }

    // @dev called from Relic during Transmutations
    function mintFromRelic(uint256 _itemId, uint256 _amount) external{
        require(msg.sender==address(RELIC));
        _mint(address(RELIC), _itemId, _amount,"");
    }

    // @dev called from Relic during Transmutations
    function burnFromRelic(uint256 _itemId, uint256 _amount) external {
        require(msg.sender==address(RELIC));
        _burn(address(RELIC), _itemId, _amount);
    }

     // @dev How partners mint their items
    function partnerMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        require(whiteListedPartners[msg.sender], "You're not authorised to mint");
        require(partnerId[msg.sender]==id, "This isn't your reserved itemId");
        _mint(account, id, amount, data);
        // revoke whitelist
        whiteListedPartners[msg.sender]=false;
    }

    //------- Internal -------//

    //------- Owner -------//

    // @dev authorise a partner to mint an item
    function addPartner(address _toAdd, uint256 _assignedItemId) external onlyOwner{
        whiteListedPartners[_toAdd] = true;
        partnerId[_toAdd]=_assignedItemId;
    }

    function removePartner(address _toRemove) external onlyOwner{
        whiteListedPartners[_toRemove]= false;
    }

    function setRelic(address _relic) external onlyOwner {
        RELIC = IRelic(_relic);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
