// contracts/VeryEmoji.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract VeryEmoji is ERC721 {
    uint256 private _currentTokenId = 0;//Token ID here will start from 1

    constructor() ERC721("VeryEmoji", "EMOJI") {
    }

    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     */
    function mintTo(address _to) public {
        uint256 newTokenId = _getNextTokenId();
        _mint(_to, newTokenId);
        _incrementTokenId();
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() private view returns (uint256) {
        return _currentTokenId+1;
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    function _incrementTokenId() private {
        _currentTokenId++;
    }

    /**
     * @dev returns the tokenURI for the specified _tokenId
     * @param _tokenId of the token
     * @return string for the tokenURI
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked("ipfs://QmarZTMidah5GKmDHrH8V4w5XBh6goid1YMqpo6XTrgVPy/", Strings.toString(_tokenId), ".json"));
    }
}
