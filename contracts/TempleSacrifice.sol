//                                       @@@                                      
//                                       @@@                                      
//                                       @@@                                      
//                                       @@@                                      
//                                       @@@                                      
//                                       @@@                                      
//                                       @@@                                      
//               @@@                    @@@@@                    @@@              
//               @@@                  @@@@@@@@@                  @@@              
//               @@@               .@@@@@@@@@@@@@.               @@@              
//               @@@             (@@@@@@@@@@@@@@@@@%             @@@              
//               @@@           @@@@@@@@@@@@@@@@@@@@@@@           @@@              
//               @@@         @@@@@@@@@@@@@@@@@@@@@@@@@@@         @@@              
//               @@@       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       @@@              
//               @@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.    @@@              
//               @@@  /@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%  @@@              
//               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@              
//               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      

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
    bool private isCustomPrice;
    uint256 public customPrice;

    function sacrifice() external {
        uint256 allowance = TEMPLE.allowance(msg.sender, address(this));
        require(allowance >= _getPrice(), "Check $TEMPLE allowance");
        TEMPLE.safeTransferFrom(msg.sender, address(this), _getPrice());
        RELIC.whitelistTemplar(msg.sender);
    }

    function _getPrice() internal view returns(uint256){
        return isCustomPrice ? customPrice :
            (10*10**18+(40*10**18*(((block.timestamp-originTime)/60/60/24)*100 /365*100))/10000);
    }

    function setAddresses(address _relic, address _temple) external onlyOwner{
        RELIC = IRelic(_relic);
        TEMPLE = IERC20(_temple);
    }

    function setOriginTime(uint256 _time) external onlyOwner{
        originTime = _time;
    }

    function setCustomPrice(uint256 _price) external onlyOwner{
        customPrice = _price;
    }

}