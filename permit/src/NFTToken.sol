// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTToken is ERC721URIStorage {

    uint private newItemId;

    constructor() ERC721(unicode"open stack", "OS") {}


    // 0x74b73FD5B6A4d5A1Bb63f713997A9CBb1dF54815
    // https://orange-naval-clownfish-219.mypinata.cloud/ipfs/QmVZn4L3VTtQV57CxWhkNbD7mD24QfXsZKvJApEYSxpRVF
    function mint(address me, string memory tokenURI)
        public
        returns (uint256)
    {
         newItemId = 0;
        _mint(me, newItemId);
        _setTokenURI(newItemId, tokenURI);
        newItemId++;
        
        return newItemId;
    }
}