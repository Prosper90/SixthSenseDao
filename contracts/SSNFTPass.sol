// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SSNFTPass is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    uint256 public cost = 1 ether;
      // <-- specify maximum amount of tokens
    uint256 public maxMintAmount = 2;
    bool public paused = false;
    uint256 idCounter = 1;

    mapping(address => bool) public whitelisted;

    constructor() ERC721("SixthSenseDao", "SSD") { // <-- specify NAME and SYMBOL
        setBaseURI(
            "ipfs://QmRf3Ak3FFVSnLnknG8Rhtxoyq4APAumVNC3kiFGF9uo7q" //  <-- specify IPFS uri to ipfs.json
        );
    }

    function addWhiteListed(address[] calldata receivers) external onlyOwner {
        for (uint256 i = 0; i < receivers.length; i++) {
            whitelisted[receivers[i]] = true;
        }
    }


    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint() public payable returns (bool success){
        uint256 supply = totalSupply() + idCounter;
        require(!paused);
        require(balanceOf(msg.sender) <= maxMintAmount);

        if (msg.sender != owner()) {
            if (whitelisted[msg.sender] != true) {
                require(msg.value >= cost);
               _safeMint(msg.sender, supply);
               return true;
            }
        }

     _safeMint(msg.sender, supply);
     return true;

    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI
                    )
                )
                : "";
    }

    // only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }


    function pause(bool _state) public onlyOwner {
        paused = _state;
    }


    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }


    function withdraw() public payable onlyOwner {
        // =============================================================================

        // This will payout the owner 100% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
