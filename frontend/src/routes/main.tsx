import React, {FC, useState} from 'react';
import {Box, Text, Flex,Button } from '@chakra-ui/react'
import { mintAnimalTokenContract } from '../contracts';
import AnimalCard from "../components/AnimalCard"

interface MainProps{
    account: string; 
}

const Main: FC<MainProps> = ({account}) =>{

    const [newAnimalType, setNewAnimalType] = useState<string>();

    const onClickMint = async () => {
        try{
            if(!account) return; 

        const response = await mintAnimalTokenContract.methods.mintAnimalToken().send({
                from: account
            });

        if(response.status){
            const balanceLength = await mintAnimalTokenContract.methods.balanceOf(account).call();

            //최근 인덱스를 가져옴 
            const animalTokenId = await mintAnimalTokenContract.methods.tokenOfOwnerByIndex(account, parseInt(balanceLength.length,10) - 1 ).call()

            //최근 인덱스의 애니멀 타입을 가져옴 
            const animalType = await mintAnimalTokenContract.methods.animalTypes(animalTokenId).call();

            //애니멀 카드로 보내서 이미지를 띄우기
            setNewAnimalType(animalType);
        }

        }catch (error){
            console.log(error)
        }
    };
    return <div>
        <Flex
        w="full"
        h="100vh"
        justifyContent="center"
        alignItems="center"
        direction="column"
        >
        <Box>
            {newAnimalType ? (<AnimalCard animalType={newAnimalType}  />): <Text>Let's mint Animal Card </Text>}
        </Box>
        <Button mt={4} size="sm" colorScheme="blue" onClick={onClickMint} >Mint</Button>
        </Flex>
    </div>
}

export default Main;