pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @notice interfaced from Relic.sol to obtain address balance of token, 
* token Id owned by owner at given index of token list, 
* information from Relic.sol regarding enclave type.
*/
interface IRelic {
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
contract PathofTheTemplarShard is AccessControl {

    IShards private SHARDS;
    IRelic private RELIC;
    //Mapping SHARD_ID to the individual enclaves
    uint256[] public SHARD_ID = [1, 2, 3, 4, 5];
    string[] public ENCLAVE = ["", "chaosEnclave", "mysteryEnclave", "logicEnclave", "structureEnclave", "orderEnclave"];

    using Counters for Counters.Counter;

    bytes32 constant MINTREQUEST_TYPEHASH = keccak256("MintRequest(address signer,uint256 deadline,uint256 nonce)");
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId)");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 immutable public DOMAIN_SEPARATOR;

    struct MintRequest {
        address account;
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
        if (msg.sender != signer ) {
            revert MintForbidden("MintForbidden");
        }

        _;
    }

//mapping the Shard ID from its declared array to the Enclave names
mapping(uint256 => string) public shardToEnclave;
// mapping address to nonces for incremental counter
mapping(address => Counters.Counter) public nonces;

// Constructor occurs just once during deployment of contract 
// original deployer is granted the default admin role
// Shards and domain separator constant is initialised
// using name, version and Arbitrum Goerli chainID.
constructor(IShards shards, uint256 chainId) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        SHARDS = shards;
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "PathofTheTemplarShard",
            version: '1',
            chainId: 421613
        }));
    }
// setMintRequest grants the address calling this function the ability to mint if the check
// using EIP712 standard below are passed (with signature verification, deadline and nonce)
function setMintRequest(address account, bytes calldata signature) external canMint {
    SHARDS.partnerMint(msg.sender, SHARD_ID[0], 1, "");
}

//for loop checks if the Enclave name matches the Shard ID
function establishMapping() public {
    // Establish the mapping between SHARD_ID and ENCLAVE
    for (uint256 i = 1; i < SHARD_ID.length; i++) {
    shardToEnclave[SHARD_ID[i]] = ENCLAVE[i];
    }
}

// Shard Id corresponding to Enclave can be viewed publically by anyone calling this function
function getEnclaveForShard(uint256 shardId) public view returns (string memory) {
        return shardToEnclave[shardId];
    }

// Function takes two parameters request and signature 
function relayMintRequestFor(MintRequest calldata request, bytes calldata signature) external {
    //concatenates the three values into a digest via a keccak256 hash function
    bytes32 digest = keccak256(abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        hash(request)
        ));
        //recover the signer with the signature by comparing the public key with the private key
        (address signer, ECDSA.RecoverError err) = ECDSA.tryRecover(digest, signature);
        // Check for error in signature recovery process
        if (err != ECDSA.RecoverError.NoError) {
            revert InvalidSignature(request.account);
        }
        // Check for error if deadline is expired
        if (block.timestamp > request.deadline) revert DeadlineExpired(block.timestamp - request.deadline);
        // Check for error if authorized Minter matches signer
        if (signer != request.account) revert InvalidSignature(request.account);
        // Checks for error if nonce is valid for authorized Minter
        if (_useNonce(request.account) != request.nonce) revert InvalidNonce(request.account);
        // Set the provided deadline and nonce for the Set Quest Completed Message.
        grantRole(MINTER_ROLE, request.account);
 
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
/**
* @dev hash function stores custom data type QuestCompletedMessageReq with input values
* of signer, deadline and nonce into a bytes32 hash.
*/
    function hash(MintRequest memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            MINTREQUEST_TYPEHASH,
            _input.account,
            _input.deadline,
            _input.nonce
        ));
    }

    function hash(uint256[] memory _input) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_input));
    }

}