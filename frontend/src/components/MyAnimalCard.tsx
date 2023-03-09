import React, {FC} from "react";
import AnimalCard from "./AnimalCard";
import {Box} from "@chakra-ui/react"

interface MyAnimalCardProps{
    animalType: string; 
}


const MyAnimalCard: FC<MyAnimalCardProps> = ({animalType})=>{
    return (
        <Box>
            <AnimalCard  animalType={animalType}/>
        </Box>
    )
}