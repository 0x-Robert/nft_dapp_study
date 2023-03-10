// SPDX-License-Identifier: MIT 

//버전 명시 
pragma solidity ^0.8.0; 

//mint 함수 컨트랙트 추가 
import "./MintAnimalToken.sol";

//판매 컨트랙트 설정 
//민트 컨트랙트가 있어야 하므로 실행과정은 다음과 같다.
// MintAnimalToken을 deploy
// 이후 SaleAnimalToken 배포
// mintAnimalToken 함수로 NFT를 민트한다.  
// MintAnimalToken의 setApprovedForAll 함수에서 operator로 판매 컨트랙트주소를 넣고 bool값에 true로 권한을 허용해줘야함 
// 이후 isApprovedForAll을 실행해준다. owner 계정과 판매컨트랙트 계정을 입력해준다. 
// 이후 SaleAnimalToken의 setForSaleAnimalToken함수를 호출한다.  가격과 토큰 아이디를 설정한다. 



contract SaleAnimalToken {
    //MintAnimalToken 어드레스를 담을 주소를 선언 
    MintAnimalToken public mintAnimalTokenAddress;

    //생성자, 컨트랙트 빌드시 한번 실행됨 
    constructor (address _mintAnimalTokenAddress){
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }   

    //animalTokenId가 입력이면 출력은 animalTokenPrices로 설정함 
    //왜? 속성 체크때문에 설정했다.
    mapping(uint256 => uint256 ) public animalTokenPrices; 

    //프론트에서 이 배열을 가지고 어떤 토큰이 판매중인지 확인하기 위한 배열 
    uint256[] public onSaleAnimalTokenArray; 


    //함수 인자에 대한 설명 
    //무엇을 판매할지 >> AnimalTokenID(왜? 유일한 값이니까) , 얼마에 팔지 >> _price
    //함수범위는 public  
    function setForSaleAnimaltoken(uint256 _animalTokenId, uint256 _price ) public {
        // address 변수 animalTokenOwner = constructor에서 생성한 mintAnimalTokenAddress의 속성 ownerOf(주인이 누군지 출력해줌)
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        //주인이 맞는지 확인 require로 조건 체크 1 / 아닐 경우 다음 에러 출력 
        require(animalTokenOwner == msg.sender, "Caller is not animal token owner! ");

        //가격이 0초과여야 한다. 아닐 경우 다음 에러 출력  
        require(_price > 0, "Price is zero or lower.");

        //animalTokenPrices의 가격이 0인지 체크, 0이 아니라는 것은 이미 판매중이라는 뜻 따라서 0이 아닐 경우 다음과 같은 에러가 출력된다. 
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale");

        //isApprovedForAll에는 2개의 인자가 있다. 첫 번째는 컨트랙트의 Owner, 2번째 address[this]에서 this는 이 컨트랙트(salesAnimal contract)를 말한다. 
        //이 주인이 이 판매계약서, 즉 스마트 컨트랙트의 판매권한을 넘겼는지 체크하는 구문이라고 보면된다. 왜냐하면 이 스마트컨트랙트가 1개의 파일인데 
        // 이상한 스마트컨트랙트로 코인을 보내면 코인이 묶여서 영원히 찾을 수 없다. 그래서 이 함수가 ERC721에서 만들어졌다. 
        //true일 때만 판매 등록 가능 false는 판매등록 안됨 
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token." );

        //animalTokenId에 해당하는 값을 넣어준다.
        animalTokenPrices[_animalTokenId] = _price;

        //판매 중인 _animalTokenId, 즉 NFT를 배열에 추가해준다. 
        onSaleAnimalTokenArray.push(_animalTokenId);

    }

    //구매 컨트랙트 
    function purchaseAnimalToken(uint256 _animalTokenId) public payable{
        //판매 가격 변수 설정 
        uint256 price = animalTokenPrices[_animalTokenId];
        
        //mintAnimalTokenAddress의 주소의 owner 변수 설정 
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        //판매금액이 0보다 큰지 체크 
        require(price > 0, "Animal token not sale");

        //msg.value는 이 함수를 실행할 때 보내는 토큰 양
        require(price <= msg.value, "Caller sent lower than prie" );

        //판매할 때 판매자가 owner인것과는 달리 구매자는 owner가 아니여야 구매가 되므로 설정함
        //즉 token owner와 구매자는 같지 않다는 것을 체크하기 위한 구문 
        require(animalTokenOwner != msg.sender, "Caller is animal token owner");

        //구매로직 
        //다음 구문 때문에 함수에서 payable이 필요했다. 
        //이 함수를 실행한 msg.sender에게 msg.value(nft의 가격)만큼의 토큰 양이 animalTokenOwner에게 간다. 
        //즉 구매처리되서 판매가격은 주인한테 전송한다는 뜻이다. 
        payable(animalTokenOwner).transfer(msg.value);

        //인자 3개, 첫 번재 보내는 사람, 받는 사람, 애니멀 토큰아이디(NFT 고유아이디)
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);        


        //매핑에서 제거 
        animalTokenPrices[_animalTokenId] = 0;

        //판매중인 목록에서 제거, 배열에서 제거 
        //onSaleAnimalTokenArray 판매중인 NFT 배열 크기만큼 순회 
        for(uint256 i=0; i < onSaleAnimalTokenArray.length; i++){
            //위 코드에서 매핑에서 제거한 값이 0이되었으므로 구매로직이 끝난 NFT토큰을 조건문으로 찾는다. 
            if(animalTokenPrices[onSaleAnimalTokenArray[i]] == 0 ){
                //onSaleAnimalTokenArray[i] 즉 구매로직이 끝난 배열값에 마지막 배열값을 대입하면 
                //구매로직이 끝난 배열값은 사라진다. 
                
                //예를 들면 onSaleAnimalTokenArray의 길이가 총 5이고 마지막 값이 3일 때 (onSaleAnimalTokenArray[4]==3) 
                //onSaleAnimalTokenArray[2] == 0 일 때 3번째 인덱스의 값이 매핑에서 제거되고 구매도 끝났다면 
                // onSaleAnimalTokenArray[2] == 3(마지막 배열 값을 대입)한 후 배열에서 마지막 값을 pop으로 빼주면
                //구매로직이 끝난 배열은 사라졌고 기존 마지막 배열값도 사라졌으므로 판매중인 NFT 목록에서 완벽하게 제거됐다. 
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length-1];
                onSaleAnimalTokenArray.pop(); 
            }

        }
    }
    function getOnSaleAnimalTokenArrayLength() view public returns (uint256){
        return onSaleAnimalTokenArray.length;
    }

    function getAnimalTokenPrice(uint256 _animalTokenId) view public returns (uint256){
        return animalTokenPrices[_animalTokenId];
    }
}
