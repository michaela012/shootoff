import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";
import { isValidSuiObjectId } from "@mysten/sui.js/utils";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import React from "react";
import { useState } from "react";
import { OwnedObjects } from "./components/UserInfo";
import { GameWindow } from "./components/GameWindow";
import { CreateGame } from "./components/CreateGame";
import { JoinGame } from "./components/JoinGame";
import bullet from './img/bullet.png';
import red_heart from './img/red-heart.png';
import blank_heart from './img/blank-heart.png';
import gun from './img/gun.png';
import mirror from './img/mirror.png';
import reload from './img/reload.png';
import cowboy_hat from './img/cowboy_hat.png';
import background from './img/mountains.jpeg';
import '../styles.css'

function App() {
  const [game_active, set_game_active] = React.useState(false);
  const [game_id, set_game_id] = React.useState("");
  const [isCopied, setIsCopied] = React.useState(false);

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text)
      .then(() => {
        setIsCopied(true); // Show confirmation message
        setTimeout(() => setIsCopied(false), 2000); // Hide after 2 seconds
      })
      .catch(err => {
        console.error('Error in copying text: ', err);
      });
  };


  ///
  return (
    <div 
    style={{ 
      backgroundImage: `url(${background})`, // Using the imported image
      minHeight: '100vh', // Minimum height of 100% of the viewport height
      backgroundSize: 'cover', // Cover the entire area
      backgroundPosition: 'center', // Center the background image
      backgroundAttachment: 'fixed' // Background is fixed during scroll
    }}
  >
    <>
      <Flex
        position="sticky"
        px="4"
        py="2"
        justify="between"
        style={{
          borderBottom: "1px solid var(--gray-a2)",
        }}
      >
        <Box 
        className="bounce"
        style={{ 
          display: 'flex', 
          justifyContent: 'center', // Center horizontally
          alignItems: 'center', // Center vertically
          width: '100%', // Take full width to allow centering within the parent container
          height: '150px'
        }}>
          <Heading id="name" style={{ color: '#654321' }}>SHOOTOUT</Heading>
          <img src={cowboy_hat} alt="Cowboy Hat" 
            style={{ 
              width: '150px', 
              height: '150px', 
              marginTop: '30px', 
              marginLeft: '10px'}} />
        </Box>

        <Box>
          <ConnectButton />
        </Box>
      </Flex>

      <Container
        style={{ 
          
        }}
      >
        <Container
          style={{ 
            minHeight: '100vh',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            padding: '20px',
          }}
        >
          {
            game_active ? (
            <div style={{ 
              padding: '20px', 
              border: '1px solid #ccc', 
              borderRadius: '8px',
              textAlign: 'center',
              margin: '10px 0',
              backgroundColor: 'brown'
            }}>
              <div> Game Code (click to copy): </div>
              <div 
                onClick={() => copyToClipboard(game_id)}
                style={{
                  cursor: 'pointer',
                  fontWeight: 'bold',
                  marginBottom: '10px',
                  display: 'inline-block',
                  backgroundColor: 'gray'
                }}
              >
                {game_id}
              </div>
              {isCopied && <div style={{ color: 'rgb(58, 209, 48) ' }}>Copied to clipboard!</div>} {/* Confirmation message */}
            </div>
          ) : (
            <div 
            style={{ 
              flexGrow: 1, 
              display: 'flex', 
              flexDirection: 'column', 
              justifyContent: 'space-evenly',
              width: '80%',
              textAlign: 'center'
            }}>
              <div style={{ padding: '40px', border: '1px solid #ccc', borderRadius: '8px', marginBottom: '20px' }}>
                <CreateGame
                  onCreated={(id) => {
                    set_game_id(id);
                    set_game_active(true);
                  }}
                />
              </div>
              <div style={{ padding: '40px', border: '1px solid #ccc', borderRadius: '8px' }}>
                <JoinGame
                  onJoined={(id) => {
                    set_game_id(id);
                    set_game_active(true);
                  }}
                />
              </div>
            </div>
          )}
        </Container>
      </Container>  
    </>
    </div>
  );
}

export default App;

{/* <img src={red_heart} alt="Red Heart" style={{ width: '100px', height: '100px' }} />
<img src={blank_heart} alt="Blank Heart" style={{ width: '100px', height: '100px' }} />
<img src={gun} alt="Gun" style={{ width: '100px', height: '100px' }} />
<img src={mirror} alt="Mirror" style={{ width: '100px', height: '100px' }} />
<img src={reload} alt="Reload" style={{ width: '100px', height: '100px' }} /> 
<img src={bullet} className="bounce" id="Bullet" alt="Bullet" style={{ width: '100px', height: '100px' }}/>
*/}