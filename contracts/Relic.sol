// unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Relic is
    ERC1155,
    Ownable,
    Pausable,
    ERC1155Burnable,
    ERC1155Supply,
    ReentrancyGuard
{
    constructor() ERC1155("") {}

    mapping(uint256 => Recipe) public recipes;
    mapping(address => uint256) public activeRelic;
    mapping(address => bool) public relicAuthority;

    address private relicCreator;

    struct Recipe {
        uint16 id;
        uint256[] requiredIds;
        uint256[] requiredAmounts;
        uint256[] rewardIds;
        uint256[] rewardAmounts;
    }

    event Transmutation(address Templar, uint256 recipeId);

    modifier hasAuthority() {
        require(relicAuthority[msg.sender], "No authority");
        _;
    }

    modifier hasActiveRelic() {
        require(activeRelic[msg.sender] > 0, "You don't have an active Relic");
        _;
    }

    //------- External -------//

    // templar forges a Relic. Can be done through Temple only as another contract will take care of staking ?
    function createRelic(address _templar) external hasAuthority {
        activeRelic[_templar] = 1;
    }

    // same has create, going to be called from another contract if we want to released staked
    // temple upon burn?
    function renounceRelic(address _templar) external hasAuthority {
        // check Templar has a Relic
        require(activeRelic[_templar] > 0);
        // change activeRelic to -1
        activeRelic[_templar] = 0;
    }

    // use receipes to transform ingredients into a new item
    function transmute(uint256 _recipeId, bytes memory _data)
        external
        nonReentrant
        hasActiveRelic
    {
        Recipe memory transmutation = recipes[_recipeId];
        // Destroy
        for (uint256 i = 0; i < transmutation.requiredIds.length; i++) {
            require(
                balanceOf(msg.sender, transmutation.requiredIds[i]) >=
                    transmutation.requiredAmounts[i],
                "Not enough ingredients"
            );
            _burn(
                msg.sender,
                transmutation.requiredIds[i],
                transmutation.requiredAmounts[i]
            );
        }
        // Create
        for (uint256 i = 0; i < transmutation.rewardIds.length; i++) {
            _mint(
                msg.sender,
                transmutation.rewardIds[i],
                transmutation.rewardAmounts[i],
                _data
            );
        }

        emit Transmutation(msg.sender, _recipeId);
    }

    // In the case Templars wish to move some items outside of their relic
    function transferItemTo(
        address _to,
        uint256 _itemId,
        uint256 _amount,
        bytes memory _data
    ) external hasActiveRelic {
        require(
            balanceOf(msg.sender, _itemId) >= _amount,
            "Not enough ingredients"
        );
        _safeTransferFrom(msg.sender, _to, _itemId, _amount, _data);
    }

    //------- Internal -------//

    //------- Owner -------//

    function addAuthority(address _toAdd) external onlyOwner{
        relicAuthority[_toAdd] = true;
    }

    function removeAuthority(address _toRemove) external onlyOwner{
        relicAuthority[_toRemove]= false;
    }

    function createRecipe(
        uint256 _recipeId,
        uint256[] memory _requiredIds,
        uint256[] memory _requiredAmounts,
        uint256[] memory _rewardIds,
        uint256[] memory _rewardAmounts
    ) external onlyOwner {
        recipes[_recipeId].id = uint16(_recipeId);
        recipes[_recipeId].requiredIds = _requiredIds;
        recipes[_recipeId].requiredAmounts = _requiredAmounts;
        recipes[_recipeId].rewardIds = _rewardIds;
        recipes[_recipeId].rewardAmounts = _rewardAmounts;
    }

    function setRelicCreator(address _new) external onlyOwner {
        relicCreator = _new;
    }

    // create new items
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    // create new items batch
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
