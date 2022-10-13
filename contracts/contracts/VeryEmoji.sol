// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract VeryEmoji is ERC721, ERC721Enumerable {
    uint256 private _maxSupply = 88;
    uint256[] private _mintedTokenIds;

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
     * @dev returns the minted TokenId array
     * @return uint256[] for the minted TokenId array
     */
    function mintedTokenIds()
        public
        view
        returns (uint256[] memory)
    {
        return _mintedTokenIds;
    }

    /**
     * @dev Mints a token to msg.sender
     * @param _tokenId of the token
     */
    function mint(uint256 _tokenId) public {
        require(_tokenId < _maxSupply);
        _mint(msg.sender, _tokenId);
        _mintedTokenIds.push(_tokenId);
    }

    /**
     * @dev returns the tokenURI for the specified _tokenId
     * @param _tokenId of the token
     * @return string for the tokenURI
     */
    function tokenURI(uint256 _tokenId)
        public
        pure
        override
        returns (string memory)
    {
        return string(abi.encodePacked("ipfs://QmSxvj2y3ktM8EErNvzfBiUBFDBNRW4GBTomGpvrfM25Td/", Strings.toString(_tokenId)));
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
