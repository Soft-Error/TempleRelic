pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "

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


}