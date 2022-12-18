pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface IRelic {
    function whitelistTemplar(address _toWhitelist) external;
}

contract TempleSacrifice is Ownable {

    using SafeERC20 for IERC20;


    IRelic public RELIC;
    IERC20 public TEMPLE;
    uint256 private originTime;

    function sacrifice() external {
        uint256 allowance = TEMPLE.allowance(msg.sender, address(this));
        require(allowance >= _getPrice(), "Check $TEMPLE allowance");
        require(TEMPLE.transferFrom(msg.sender,address(this),_getPrice()), "Not exact amount");
        RELIC.whitelistTemplar(msg.sender);
    }

    function _getPrice() internal view returns(uint256){
        return 10 + 40* ((block.timestamp - originTime)/60/60/24)/365 * 10**18;
    }

    function setRelic(address _relic) external onlyOwner{
        RELIC = IRelic(_relic);
    }

    function setOriginTime(uint256 _time) external onlyOwner{
        originTime = _time;
    }

}