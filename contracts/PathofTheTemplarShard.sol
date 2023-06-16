pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./PartnerMinter.sol/";

interface IRelic {
    function balanceOf(address) external returns (uint256);
    function tokenOfOwnerByIndex(address, uint256) external returns (uint256);
}

interface IShards {
    function partnerMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}

contract PathofTheTemplarShard is ownable {
    IShards private SHARDS,
    IRelic private RELIC,
    uint256 public SHARD_ID = 2;

function mintPathofthetemplarshard() public canMint() {

}

function signedQuestCompletedMessage(QuestCompletedMessageReq calldata req, bytes calldata signature) external {

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(req)
        ));

        (address signer, ECDSA.RecoverError err) = ECDSA.tryRecover(digest, signature);
        if (err != ECDSA.RecoverError.NoError) {
            revert InvalidSignature(req.account);
        }
        if (block.timestamp > req.deadline) revert DeadlineExpired(block.timestamp - req.deadline);
        if (signer != req.account) revert InvalidSignature(req.account);
        if (_useNonce(req.account) != req.nonce) revert InvalidNonce(req.account);

        _setQuestCompletedMessage(req.account, req.discordIds);
    }

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
            _input.chainId
        ));
    }

    struct QuestCompletedMessageReq {
        address account;
        uint256[] discordIds;
        uint256 deadline;
        uint256 nonce;
    }

    bytes32 constant SIGNEDQUESTCOMPLETEDMESSAGE_TYPEHASH = keccak256("QuestCompletedMessageReq(address account,uint256[] discordIds,uint256 deadline,uint256 nonce)");

    function hash(QuestCompletedMessageReq memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            SIGNEDQUESTCOMPLETEDMESSAGE_TYPEHASH,
            _input.account,
            hash(_input.discordIds),
            _input.deadline,
            _input.nonce
        ));
    }

    function hash(uint256[] memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_input));
    }
}