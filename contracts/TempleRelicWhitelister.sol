pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


error HashFail();
error HashUsed();
error InvalidSignature();

interface IRelic {
    function whitelistTemplar(address _toWhitelist) external;
}

contract TempleRelicWhitelister is Ownable {
    using ECDSA for bytes32;

    address public signer;
    IRelic private RELIC;

    modifier isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) {
        if (!_matchSigner(hash, signature)) revert InvalidSignature();
        if (hash != _hashTransaction(msg.sender))
            revert HashFail();
        _;
    }

    ///////////////// external /////////////////

    function addToWhitelist(bytes32 _hash,bytes memory _signature, address _address) external isValidSignature(_hash, _signature)  {
        RELIC.whitelistTemplar(_address);
    } 

    ///////////////// private /////////////////

    function _hashTransaction(
        address sender
    ) private pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(sender))
                .toEthSignedMessageHash();
    }

    function _matchSigner(bytes32 hash, bytes memory signature)
        private view returns (bool)
    {
        return signer == hash.recover(signature);
    }

    ///////////////// Owner /////////////////

    function setSigner(address _newSigner) external onlyOwner{
        signer = _newSigner;
    }

    function setRelic(address _relic) external onlyOwner{
        RELIC = IRelic(_relic);
    }

}