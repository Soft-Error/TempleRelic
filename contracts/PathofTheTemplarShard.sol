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
    //Mapping SHARD_ID to the individual enclaves
    uint256[] public SHARD_ID = [1, 2, 3, 4, 5];
    string[] public ENCLAVE = ["", "chaosEnclave", "mysteryEnclave", "logicEnclave", "structureEnclave", "orderEnclave"];

    using Counters for Counters.Counter;

    bytes32 immutable public DOMAIN_SEPARATOR;
    //added bytes 32 digest to this struct
    struct QuestCompleteReq {
        address signer;
        bytes32 digest;
        uint256 deadline;
        uint256 nonce;
    }

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
    }

    error TooManyMessages();
    error MintForbidden();

    error DeadlineExpired(uint256 lateBy);
    error InvalidNonce(address account);
    error InvalidSignature(address account);

    modifier canMint() {
        if (msg.sender != signer) {
            revert MintForbidden();
        }

        _;
    }

mapping(uint256 => string) public shardToEnclave;
mapping(bytes32 => address) signedQuestCompletedMessage;
mapping(address => uint256[]) public questCompletedMessageBy;
mapping(address => Counters.Counter) public nonces;
//TODO Fix the msg.sender as the only authorizedMinter
constructor() {
        authorizedMinters = msg.sender;

        EIP712Domain memory domain = EIP712Domain({
            name: "PathofTheTemplarShard",
            version: "1",
            chainId: 421613
        });
        DOMAIN_SEPARATOR = hash(domain);
    }

function establishMapping() public {
    // Establish the mapping between SHARD_ID and ENCLAVE
    for (uint256 i = 1; i < SHARD_ID.length; i++) {
    shardToEnclave[SHARD_ID[i]] = ENCLAVE[i];
    }
}

function mintPathofthetemplarShard() external canMint {
    SHARDS.partnerMint(msg.sender, SHARD_ID[], 1, "");
}

function getEnclaveForShard(uint256 shardId) public view returns (string memory) {
        return shardToEnclave[shardId];
    }

function setAuthorization(uint256[] calldata signer) external {
        _setAuthorization(msg.sender, signer);
}
//TODO I believe I should remove the second variable
function _setAuthorization(address account, uint256[] calldata signer) internal {
    if (signer.length > 1) {
        revert TooManyMessages();
    }
//TODO State the right variable
    questCompletedBy[owner] = signer;
}

//This function creates a hashed message for the message signer to confirm their signature
//TODO Change and shorten naming convention of functions and parameter. Some of the codebase
//can be further shortened as some parts are not relevant to my use case.
//The keccak256 method to obtain the bytes32 digest below is fine but I need to adjust the definitions of
//user, account, signer, msg.sender and authorizedMinter
function relayedSignatureFor(QuestCompleteReq calldata req, bytes calldata signature) external {
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
            revert InvalidSignature(req.account);
        }
        // Check for error if deadline is expired
        if (block.timestamp > req.deadline) revert DeadlineExpired(block.timestamp - req.deadline);
        // Check for error if authorized Minter matches signer
        if (signer != req.account) revert InvalidSignature(req.account);
        // Checks for error if nonce is valid for authorized Minter
        if (_useNonce(req.account) != req.nonce) revert InvalidNonce(req.account);
        // Set the provided deadline and nonce for the Set Quest Completed Message.
        _setAuthorization(req.authorizedMinter, req.enclaves);
 
    }

    /**
     * "Consume a nonce": return the current value and increment.
     */
    function _useNonce(address _owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_owner];
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
    bytes32 constant SIGNEDQUESTCOMPLETE_TYPEHASH = keccak256("QuestCompleteReq(address signer,uint256 deadline,uint256 nonce)");

/**
* @dev hash function stores custom data type QuestCompletedMessageReq with input values
* of signer, deadline and nonce into a bytes32 hash.
*/
    function hash(AuthorizationReq memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            SIGNEDQUESTCOMPLETE_TYPEHASH,
            _input.signer,
            _input.deadline,
            _input.nonce
        ));
    }

    function hash(uint256[] memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_input));
    }

}