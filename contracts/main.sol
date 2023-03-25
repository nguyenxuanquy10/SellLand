// SPDX-License-Identifier: UNDEFINER
// ong vuong : ban mieng dat
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./land.sol";

// https://honorable-provelone-2a6.notion.site/B-i-t-p-bu-i-14-e680469c9bd449d9880251350724bd35
// youtube : https://www.youtube.com/watch?v=GwFQg8ROZfo&t=292s

contract Main is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // admin
    mapping(uint256 => Land[]) areaToLand;
    mapping(uint256 => uint256) areaToBidPrice;
    mapping(uint256 => mapping(uint256 => uint256)) landToTokenId;
    // seller
    mapping(uint256 => uint256) landToPrice;
    mapping(uint256 => mapping(uint256 => bool)) locationToLand;
    mapping(uint256 => mapping(uint256 => address)) locationToSeller;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    // admin  ông vuong
    function awardItem(string memory tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri,
        uint256 x,
        uint256 y
    ) external onlyOwner {
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
        landToTokenId[x][y] = _tokenId;
    }

    // add land to area
    function addLandToArea(
        uint256 x,
        uint256 y,
        uint256 area
    ) public onlyOwner {
        areaToLand[area].push(Land(x, y, false));
    }

    // add bid price of area from admin for seller
    function addBidPriceArea(uint256 price, uint256 area) public onlyOwner {
        areaToBidPrice[area] = price;
    }

    // change bid price of area
    function changeBidPriceArea(uint256 price, uint256 area) public onlyOwner {
        areaToBidPrice[area] = price;
    }

    // approve right sell land from admin to seller
    function approvalAreaToSeller(
        uint256 area,
        address seller,
        uint256 bidPriceSeller
    ) public onlyOwner {
        uint256 bidCurrent = areaToBidPrice[area];
        require(bidPriceSeller >= bidCurrent, "Invalid ");
        for (uint i = 0; i <= 3; i++) {
            Land memory currentLand = areaToLand[area][i];
            uint256 currentX = currentLand.x;
            uint256 currentY = currentLand.y;
            uint256 tokenIdLand = landToTokenId[currentX][currentY];
            approve(seller, tokenIdLand);
            locationToLand[currentX][currentY] = false;
            locationToSeller[currentX][currentY] = seller;
        }
    }

    // seller
    // check land is start from
    modifier isStart(uint256 x, uint256 y) {
        require(locationToLand[x][y] == true, "Invalid");
        _;
    }
    // check is seller
    modifier isSeller(uint256 x, uint256 y) {
        require(locationToSeller[x][y] == msg.sender, "Invalid ");
        _;
    }

    // set price land from seller
    function setPriceForLand(
        uint256 price,
        uint256 x,
        uint256 y
    ) public isSeller(x, y) {
        uint256 tokenId = landToTokenId[x][y];
        landToPrice[tokenId] = price;
    }

    // set status start for land from seller
    function startSell(uint256 x, uint256 y) public isSeller(x, y) {
        locationToLand[x][y] = true;
    }

    // set status end for land from seller
    function endSell(uint256 x, uint256 y) public isSeller(x, y) {
        locationToLand[x][y] = false;
    }

    // seller to buyer
    function seller(uint256 x, uint256 y, uint256 price) public isStart(x, y) {
        uint256 tokenLand = landToTokenId[x][y];
        uint256 currentPrice = landToPrice[tokenLand];
        require(price >= currentPrice, "Invalid");
        address ownerLand = owner();
        safeTransferFrom(ownerLand, msg.sender, tokenLand);
    }
}
