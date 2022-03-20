// unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Relic is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply, ReentrancyGuard {
    constructor() ERC1155("") {}

    mapping(uint256 => Recipe) public recipes;

    struct Recipe {
        uint16 id;
        uint256[] requiredIds;
        uint256[] requiredAmounts;
        uint256[] rewardIds;
        uint256[] rewardAmounts;
    }

    event Transmutation(address Templar, uint256 recipeId);

    //------- External -------//

    // we mint tokenId 0, which indicates the Templar owns a Relic
    function createRelic () external {
        
    }

    function transmute(uint256 _recipeId, bytes memory _data) external nonReentrant{
        Recipe memory transmutation = recipes[_recipeId];
        // Destroy
        for (uint i=0;i<transmutation.requiredIds.length;i++){
            require(balanceOf(msg.sender,transmutation.requiredIds[i])>=transmutation.requiredAmounts[i]);
            _burn(msg.sender, transmutation.requiredIds[i], transmutation.requiredAmounts[i]);
        }
        // Create
        for (uint i=0;i<transmutation.rewardIds.length;i++){
            _mint(msg.sender, transmutation.rewardIds[i], transmutation.rewardAmounts[i], _data);
        }

        emit Transmutation(msg.sender, _recipeId);
    }

    function renounceRelic() external {
        // check Templar has a Relic
        require(balanceOf(msg.sender, 0)>0);
        
    }

    //------- Internal -------//

    //------- Owner -------//

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

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
