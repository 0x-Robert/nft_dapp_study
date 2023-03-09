import React, { FC, useState,useEffect } from "react";
import {mintAnimalTokenContract, saleAnimalTokenAdress} from "../web3Config"
import {Flex, Grid, Box , Text, Button, keyframes} from '@chakra-ui/react'
import AnimalCard from "../components/AnimalCard"



//서버에서 구매컨트랙트에 대해서 예외처리를 하기보다는 스마컨트랙트에서 반환하는 예외처리값을 http로 받아서 클라이언트로 리스폰스한다. 
//유저 어드레스가 클라이언트가 안줄때 예외처리는 서버에서하고 
//컨트랙트에 있는 정보 중 


interface MyAnimalProps{
    account: string; 
}

const MyAnimal: FC<MyAnimalProps> = ({account}) => {

    console.log("mintAnimalTokenContract",mintAnimalTokenContract)
    const [animalCardArray, setAnimalCardArray] = useState<string[]>();

    const [saleStatus, SetSaleStatus] = useState<boolean>(false);


    const getAnimalTokens = async()=>{
        try{
            const balanceLength = await mintAnimalTokenContract.methods.balanceOf(account).call();


            const tempAnimalCardArray = [];


            for(let i=0; i < parseInt(balanceLength, 10); i++){
                const animalTokenId = await mintAnimalTokenContract.methods.tokenOfOwnerByIndex(account, 1).call();
                
                const animalType = await mintAnimalTokenContract.methods.animalTypes(animalTokenId).call()
        
                tempAnimalCardArray.push(animalType);
            }

            setAnimalCardArray(tempAnimalCardArray);

        }catch(error){
            console.error(error);
        }
    }

    const getIsApprovedForAll = async ()=>{
        try{

            const response = await mintAnimalTokenContract.methods.isApprovedForAll(account,  saleAnimalTokenAdress).call()


            console.log("response",response);

            if(response.status){
                SetSaleStatus(response)
            }

        }catch(error){
            console.log(error)
        }
    }

    const onClickApproveToggle =async() => {
        try{

            if(!account) return 

            const response = await mintAnimalTokenContract.methods.setApprovalForAll(saleAnimalTokenAdress, !saleStatus)
            .send({from : account})

            if(response.status){
                SetSaleStatus(!saleStatus);
            }

        }catch(error){
            console.error(error)
        }
    }

    useEffect(()=>{
        if(!account) return 
        getIsApprovedForAll();
        getAnimalTokens();
    }, [account])

    useEffect(()=>{
        console.log("animalCardArray", animalCardArray)

    }, [animalCardArray])

    return(
    <>
    <Flex>
        <Text display="inline-block">Sale Status : {saleStatus ? "True" : "False"}</Text>
        <Button size="xs" ml={2} colorScheme={saleStatus ?  "red" : "blue"} onClick={onClickApproveToggle} >

            {saleStatus ? "Cancel" : "Approve"}
        </Button>
    </Flex>
    <Grid templateColumns="repeat(4, 1fr)" gap={8}>
        {
            animalCardArray && animalCardArray.map((v,i)=>{
                return <AnimalCard key={i} animalType={v}/>;
            })
        }
    </Grid>
    </>);
}

export default MyAnimal;