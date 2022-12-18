pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IFriend{
    function ownerOf(uint256 tokenId) external returns(address);
}

contract dummynft is ERC721Enumerable, ReentrancyGuard, Ownable {
    constructor() ERC721("Highrollers", "ROLLERS") {}

    modifier isAuth(){
        require(authorized[msg.sender],"Not authorized");
        _;
    }

    using Strings for uint256;

    uint256 private mintCounter;
    mapping (uint256 => uint256) public victories;
    mapping (uint256 => uint256) public highestWin;
    mapping (address => bool) public authorized;
    mapping (address => bool) public authFriends;
    mapping (address => mapping (uint256 => bool)) public exists;
    mapping (uint256 => address) public rollToFriends;
    mapping (uint256 => uint256) public rollToFriendId;

    string public BASE_URI;
    bool private paused;

    function roll() external nonReentrant {

        _mint(msg.sender,mintCounter);  
        mintCounter++;
    }

    function addWin(uint256 _rollerId,uint256 _prize) external isAuth {
        victories[_rollerId]++;
        if(_prize>highestWin[_rollerId]) highestWin[_rollerId]=_prize;
    }

    function tokenURI(uint256 _rollId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(_rollId));
        return
            string(
                abi.encodePacked(
                    BASE_URI,
                    _rollId.toString()
                )
            );
    }

    function setAuthorized(address _address, bool _flag) external onlyOwner {
        authorized[_address]=_flag;
    }

     function setURI(string memory _uri) external onlyOwner {
        BASE_URI = _uri;
    }

    function addFriends(address _friendsAddress,bool _flag) external onlyOwner{
        authFriends[_friendsAddress]=_flag;
    }

    function pause(bool _flag) external onlyOwner{
        paused = _flag;
    }
}