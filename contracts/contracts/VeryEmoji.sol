// contracts/VeryEmoji.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract VeryEmoji is ERC721 {
    uint256 private _maxSupply = 16;

    constructor() ERC721("VeryEmoji", "EMOJI") {
    }

    /**
     * @dev returns the maxSupply
     * @return uint256 for the maxSupply
     */
    function maxSupply() 
        public
        view
        returns (uint256)
    {
        return _maxSupply;
    }

    /**
     * @dev Mints a token to msg.sender
     * @param _tokenId of the token
     */
    function mint(uint256 _tokenId) public {
        require(_tokenId <= _maxSupply);
        _mint(msg.sender, _tokenId);
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
