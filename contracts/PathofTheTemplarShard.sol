pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @notice interfaced from Relic.sol to obtain address balance of token, 
* token Id owned by owner at given index of token list, 
* information from Relic.sol regarding enclave type.
*/
interface IRelic {
    function balanceOf(address) external returns (uint256);
    function tokenOfOwnerByIndex(address, uint256) external returns (uint256);
    function getRelicInfos(uint256 enclaves) external returns (uint256);
}

/**
* @notice interfaced from Shards.sol to obtain address, token Id, amount owned and stored 
*
 */
interface IShards {
    function partnerMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;
}
/**
* @title This contract aims to allow a user to mint 
* an Enclave Shard corresponding to the Enclave quest 
* upon reaching the winning state of Path of the Temple.
* It uses EIP712 to verify that a user has signed the hashed message
*/
contract PathofTheTemplarShard is 
    Ownable,
    AccessControl 
{

    IShards private SHARDS;
    IRelic private RELIC;

    bytes32 public constant CHAOS_SHARD_MINTER = keccak256("CHAOS_SHARD_MINTER");
    bytes32 public constant MYSTERY_SHARD_MINTER = keccak256("MYSTERY_SHARD_MINTER");
    bytes32 public constant LOGIC_SHARD_MINTER = keccak256("LOGIC_SHARD_MINTER");
    bytes32 public constant STRUCTURE_SHARD_MINTER = keccak256("STRUCTURE_SHARD_MINTER");  
    bytes32 public constant ORDER_SHARD_MINTER = keccak256("ORDER_SHARD_MINTER");

    address authorizedMinters;
    uint256[] public SHARD_ID = [1, 2, 3, 4, 5];

    using Counters for Counters.Counter;

    bytes32 immutable public DOMAIN_SEPARATOR;

    struct QuestCompletedMessageReq {
        uint256[] enclaves;
        address signer;
        address authorizedMinter;
        uint256 deadline;
        uint256 nonce;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
    }

    event SignedQuestCompletedMessage(address);
    event SignedQuestCompletedMessageHash(bytes32 hash);

    error TooManyMessages();
    error MintForbidden();

    error DeadlineExpired(uint256 lateBy);
    error InvalidNonce(address account);
    error InvalidSignature(address account);

    modifier canMint() {
        if (msg.sender != authorizedMinters) {
            revert MintForbidden();
        }

        _;
    }

mapping(bytes32 => address) signedQuestCompletedMessage;
mapping(address => uint256[]) public questCompletedMessageBy;
mapping(address => Counters.Counter) public nonces;

constructor() {
        authorizedMinters = msg.sender;

        EIP712Domain memory domain = EIP712Domain({
            name: "PathofTheTemplarShard",
            version: "1",
            chainId: 421611
        });
        DOMAIN_SEPARATOR = hash(domain);
    }

function mintPathofthetemplarShard() external canMint {
    SHARDS.partnerMint(msg.sender, SHARD_ID[0], 1, "");
}

 function setQuestCompletedMessage(uint256[] calldata signer) external {
        _setQuestCompletedMessage(msg.sender, signer);
        emit SignedQuestCompletedMessage(authorizedMinters);
}

function _setQuestCompletedMessage(address authorizedMinter, uint256[] calldata signer) internal {
    if (signer.length > 1) {
        revert TooManyMessages();
    }

    questCompletedMessageBy[authorizedMinter] = signer;
}

//This function creates a hashed message for the message signer to confirm their signature
function relayedSignQuestCompletedMessageFor(QuestCompletedMessageReq calldata req, bytes calldata signature) external {
    //concatenates the three values into a digest via a keccak256 hash function
    bytes32 digest = keccak256(abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(req)
        ));
        //recover the signer with the signature by comparing the public key with the private key
        (address signer, ECDSA.RecoverError err) = ECDSA.tryRecover(digest, signature);
        // Check for error in signature recovery process
        if (err != ECDSA.RecoverError.NoError) {
            revert InvalidSignature(req.authorizedMinter);
        }
        // Check for error if deadline is expired
        if (block.timestamp > req.deadline) revert DeadlineExpired(block.timestamp - req.deadline);
        // Check for error if authorized Minter matches signer
        if (signer != req.authorizedMinter) revert InvalidSignature(req.authorizedMinter);
        // Checks for error if nonce is valid for authorized Minter
        if (_useNonce(req.authorizedMinter) != req.nonce) revert InvalidNonce(req.authorizedMinter);
        // Set the provided deadline and nonce for the Set Quest Completed Message.
        _setQuestCompletedMessage(req.authorizedMinter, req.enclaves);
        emit SignedQuestCompletedMessageHash(digest);
 
    }

    /**
     * "Consume a nonce": return the current value and increment.
     */
    function _useNonce(address _authorizedMinter) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_authorizedMinter];
        current = nonce.current();
        nonce.increment();
    }

/**
* @notice defined EIP712 domain type Hash with name, version and chain Id.
*/
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId)");
/**
* @dev hash function stores custom data type QuestCompletedMessageReq as input
* in a bytes32 hash from data input values of name, version and chainId.
*/
    function hash(EIP712Domain memory _input) internal pure returns (bytes32) { 
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(_input.name)),
            keccak256(bytes(_input.version)),
            _input.chainId
        ));
    }

/**
* @notice defined Signed Quest Completed Message type Hash with signer, expected deadline and expected nonce 
*/
    bytes32 constant SIGNEDQUESTCOMPLETEDMESSAGE_TYPEHASH = keccak256("QuestCompletedMessageReq(address signer,uint256 deadline,uint256 nonce)");

/**
* @dev hash function stores custom data type QuestCompletedMessageReq with input values
* of signer, deadline and nonce into a bytes32 hash.
*/
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