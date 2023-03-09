import React, { FC,useState, useEffect } from "react";
import { Button } from '@chakra-ui/react'
import {BrowserRouter, Routes, Route} from "react-router-dom"
import Main from "./routes/main";
import { mintAnimalTokenContract } from "./contracts";
import Layout from "./components/Layout"
import MyAnimal from "./routes/my-animal";


const App: FC = () => {

  const [account, setAccount] = useState<string>("");

  // return <Button colorScheme="blue">web3-boilerplate</Button>;

  const getAccount = async () =>{
    try{
      if (window.ethereum){
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });

        setAccount(accounts[0])
      }else{
        alert("Install Metamask")
      }
    }catch (error){
      console.log("error",error)
      }
    }
  

  useEffect(()=> {
    //console.log(account)
    getAccount();
  }, [account]);

 return (

  <BrowserRouter>
  <Layout>
  <Routes>
    <Route path="/" element={<Main account={account}/> } />
    <Route path="my-animal" element={<MyAnimal account={account}/>} />
  </Routes>
  </Layout>
  </BrowserRouter>

 );
};

export default App;
