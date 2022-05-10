pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRelicItems{
    function whitelistUser(address _userAddress, uint256 _itemId) external;
}

contract GameWhitelister is Ownable {
    IRelicItems private RELICITEMS;

    function completeQuest(uint256 _questId, bytes memory _sig) external {
        
    }

    function _verify(address _signer, string memory message, bytes memory _sig) internal pure returns(bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(ethSignedMessageHash, v, r, s) == _signer; 

    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r,bytes32 s, uint8 v){
        require(_sig.length==65, "invalid length");
        assembly {
            r := mload(add(_sig,32))
            s := mload(add(_sig,64))
            v := byte(0, mload(add(_sig,96)))
        }
    }

    function setRelicItems(address _relicItems) external onlyOwner {
        RELICITEMS = IRelicItems(_relicItems);
    }



}