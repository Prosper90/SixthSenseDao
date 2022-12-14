// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/NFTLib.sol";

contract SSDNFT is ERC721Enumerable, Ownable {
	uint256 public pos;	//new tokenID
	uint256 public mintSupply;	//current nft counts
	uint256 public maxMintSupply;	//nft count limit
	string[] public metadata;	//array that stores the uri of 5 types cars
	uint256 public minBUSD;	//the busd part of nft price
	mapping(uint256 => string) public _data;	//the metadata of each nft (tokenID => uri)
	mapping(address => uint256) public _mintAmount;	//

	IERC20 eth;


	constructor(IERC20 _eth) ERC721("SSDNFTCollection", "SSDNFT") {
		pos = 0;
		maxMintSupply = 6666;
		eth = _eth;
		minBUSD = 1 * 10 ** 18;
	}

	//this function let the owner to add or change the uri of nft
	//idx => the type index of the car
	//data => the new nft uri
	function updateMetadata(uint256 idx, string memory data) external onlyOwner {
		require(idx >= 0 && idx <5, "Invalid Car Type");
		metadata[idx] = data;
	}

	//this function let the owner to set the price of the nft (busd)
	function updateMinBUSD(uint256 _minBUSD) external onlyOwner {
		minBUSD = _minBUSD;
	}

	//extense the maxSupply if owner wants
	function updateMaxSupply(uint256 _maxSupply) external onlyOwner {
		require(_maxSupply > maxMintSupply, "That amount already exists");
		maxMintSupply = _maxSupply;
	}

	//anyone can call this function but cannot exceed the total supply
	function mint(uint256 nftAmount) external {
		require(nftAmount > 0 && nftAmount <= 5, "Mint: wrong NFT amount");
		require(mintSupply + nftAmount <= maxMintSupply, "Mint: exceed mint supply");

		uint256 busdAmount = minBUSD * nftAmount;
		eth.transferFrom(msg.sender, address(this), busdAmount);

		_mintAmount[msg.sender] += nftAmount;
		mintSupply += nftAmount;

		for (uint256 i = 0 ; i < nftAmount ; i = i + 1) {
			uint256 idx = NFTLib.chance();
			pos = pos + 1;
			_safeMint(msg.sender, pos);
			_data[pos] = metadata[idx];
		}
	}

	//only owner can call this function. the uri depends on owner's will
	function mintByOwner(address addr, string memory data) external onlyOwner {
		pos = pos + 1;
		_safeMint(addr, pos);
		_data[pos] = data;
	}

	//this function returns the token(tokenId)'s uri
	function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
		return _data[tokenId];
	}

	//ownable function that transfers the funds in this contract to the owner's wallet
	function withdrawFunds(address recipient) external onlyOwner {
		uint256 ethBalance = eth.balanceOf(address(this));
		eth.transfer(recipient, ethBalance);
	}
}