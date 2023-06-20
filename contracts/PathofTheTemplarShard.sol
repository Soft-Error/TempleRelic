pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./PartnerMinter.sol";

interface IRelic {
    function balanceOf(address) external returns (uint256);
    function tokenOfOwnerByIndex(address, uint256) external returns (uint256);
    function getRelicInfos(uint256 enclaves) external returns (uint256);
}

interface IShards {
    function partnerMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

contract PathofTheTemplarShard is Ownable {
    address authorizedMinter;

event SignedQuestCompletedMessageHash(bytes32 hash);

    IShards private SHARDS;
    IRelic private RELIC;
    uint256[] public SHARD_ID = [1, 2, 3, 4, 5];

    using Counters for Counters.Counter;
    
    bytes32 immutable DOMAIN_SEPARATOR;

mapping (msg.sender => bool) public canMint;
mapping (uint256 => enclaves) signedQuestCompletedMessage;

function mintPathofthetemplarShard() external canMint {
    SHARDS.partnerMint(msg.sender, SHARD_ID, 1, "");
}

modifier canMint() {
    require(msg.sender == authorisedMinter, "You are not allowed to mint");

    _;
}

 function setQuestCompletedMessage(uint256[] calldata signer) external {
        _setQuestCompletedMessage(msg.sender, signer);
    }

function _setQuestCompletedMessage(address authorizedMinter, uint256[] calldata signer) internal {
    if (signer.length > 1) {
        revert TooManyMessages();
    }

    questCompletedMessageBy[authorizedMinter] = signer;
    emit UpdateQuestCompletedMessage(authorizedMinter, signer);
}

    struct QuestCompletedMessageReq {
        address signer;
        uint256 deadline;
        uint256 nonce;
    }

function relayedSignQuestCompletedMessageFor(QuestCompletedMessageReq calldata req, bytes calldata signature) external {

    bytes32 digest = keccak256(abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(req)
        ));

        (address signer, ECDSA.RecoverError err) = ECDSA.tryRecover(digest, signature);
        if (err != ECDSA.RecoverError.NoError) {
            revert InvalidSignature(req.authorizedMinter);
        }
        if (block.timestamp > req.deadline) revert DeadlineExpired(block.timestamp - req.deadline);
        if (signer != req.authorizedMinter) revert InvalidSignature(req.authorizedMinter);
        if (_useNonce(req.authorizedMinter) != req.nonce) revert InvalidNonce(req.authorizedMinter);

        _setQuestCompletedMessage(req.deadline, req.nonce);
        emit SignedQuestCompletedMessageHash(digest); 
    }

    event SignedQuestCompletedMessageHash(bytes32 hash);

    /**
     * "Consume a nonce": return the current value and increment.
     */
    function _useNonce(address _owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_owner];
        current = nonce.current();
        nonce.increment();
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId)");

    function hash(EIP712Domain memory _input) internal pure returns (bytes32) { 
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(_input.name)),
            keccak256(bytes(_input.version)),
            _input.chainId,
        ));
    }

    bytes32 constant SIGNEDQUESTCOMPLETEDMESSAGE_TYPEHASH = keccak256("QuestCompletedMessageReq(address signer,uint256 deadline,uint256 nonce)");

    function hash(QuestCompletedMessageReq memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            SIGNEDQUESTCOMPLETEDMESSAGE_TYPEHASH,
            _input.signer,
            _input.deadline,
            _input.nonce
        ));
    }

    function hash(uint256[] memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_input));
    }

}