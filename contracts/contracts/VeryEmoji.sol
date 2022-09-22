// contracts/VeryEmoji.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract VeryEmoji is ERC721 {

    constructor() ERC721("VeryEmoji", "EMOJI") {
    }

    /**
     * @dev Mints a token to an address with a _tokenId.
     * @param _to address of the future owner of the token
     * @param _tokenId of the token
     */
    function mint(address _to, uint256 _tokenId) public {
        _mint(_to, _tokenId);
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
