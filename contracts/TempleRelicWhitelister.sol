pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


error HashUsed();
error InvalidSignature();

interface IRelic {
    function whitelistTemplar(address _toWhitelist) external;
}

contract TempleRelicWhitelister is Ownable {
    // constructor(address _relic, address _signer) {                 
    //           RELIC = IRelic(_relic);
    //           signer=_signer;
    // } 

    using ECDSA for bytes32;

    address private signer;
    IRelic private RELIC;
    mapping(bytes => bool) usedSignatures;


    modifier isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) {
        if (_recoverSigner(hash, signature)!=signer) revert InvalidSignature();
        if (usedSignatures[signature])
            revert HashUsed();
        _;
    }

    ///////////////// external ///////////////// isValidSignature(_hash, _signature) bytes32 _hash,bytes memory _signature

    function whitelistTemplar() external   {
        RELIC.whitelistTemplar(msg.sender);
    } 

    ///////////////// private /////////////////

     function _recoverSigner(bytes32 _hash, bytes memory signature) public pure returns(address){
        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
        return ECDSA.recover(messageDigest,signature);
    }

    ///////////////// Owner /////////////////

    function setSigner(address _newSigner) external onlyOwner{
        signer = _newSigner;
    }

    function setRelic(address _relic) external onlyOwner{
        RELIC = IRelic(_relic);
    }

}