// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "SaleAnimalToken.sol";

//다음과 같이 짧은 코드로 mint 함수를 만들수 있다. 
contract MintAnimalToken is ERC721Enumerable {
    //constructor : 스마트컨트랙트가 빌드될 때 한번 실행함 
    // ERC721(name, symbol)
    constructor() ERC721("h662Animals","HAS"){}

    SaleAnimalToken public saleAnimalToken;

    //saleAnimalToken address도 필요하지만 순서상 민트 컨트랙트가 먼저 배포되므로 최상위에 import를 써서 가져와야함

    //앞 uint256은 animalTokenId 뒤 uint256은 animalTypes 
    mapping(uint256 => uint256) public animalTypes; 

    //값을 담아서 한꺼번에 리턴할 때 struct가 필요함 
    //하단의 get함수를 위해 설정함 
    struct AnimalTokenData{
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
    }

    // function tokenURI(
    // uint256 animalTokenId
    // ) public view
    //   override(ERC721, ERC721URIStorage) returns (string memory) {
    //     return super.tokenURI(animalTokenId);
    // }
    
    function mintAnimalToken() public {
        //tokenid가 유일해야 NFT라고 할 수 있다. 
        uint256 animalTokenId = totalSupply() + 1;

        //솔리디티에서 랜덤은 다음과같이 만든다. 
        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 +1; 

        //배열에 값을 선언한다. 
        animalTypes[animalTokenId] = animalType; 

        //erc721에서 제공해주는 함수 _mint
        //msg.sender는 컨트랙트를 발행하는 사람, owner / animalTokenId는 NFT임을 증명하는 고유의 넘버 
        _mint(msg.sender, animalTokenId);
        
    }

    //프론트에서 web3 객체를 가져오려면 여러가지 반복문과 조건문으로 시간이 많이 걸리므로 조회용 get 함수를 만들어서 제공하면 속도가 개선됨 
    //다음 함수에서 struct return 값은 두가지 타입이 있다. memory(이 함수가 실행되는 동안만 저장)와 storage(블록체인에서 영구저장)
    function getAnimalTokens(address _animalTokenOwner ) view public returns(AnimalTokenData[] memory) {
        //값을 변화시키지 않는 함수는 전부 view, 조회로만 사용 

        uint256 balanceLength = balanceOf(_animalTokenOwner);

        require(balanceLength != 0, "Owner did not have token");

        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        for(uint256 i=0; i < balanceLength; i++){
            uint256 animalTokenId =  tokenOfOwnerByIndex(_animalTokenOwner,i);
            uint256 animalType = animalTypes[animalTokenId];
            //mint에서 sale contract의 가격조회함수를 가져와서 설정 다음 getAnimalTokenPrice은 sellMInt의 조회함수다. 
            uint256 animalPrice = saleAnimalToken.getAnimalTokenPrice(animalTokenId);


            animalTokenData[i] = AnimalTokenData(animalTokenId, animalType , animalPrice);
        }


        return animalTokenData;

    }

    function setSaleAnimalToken(address _saleAnimalToken) public{
        saleAnimalToken = SaleAnimalToken(_saleAnimalToken);
    }

}