import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";
import { isValidSuiObjectId } from "@mysten/sui.js/utils";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import React from "react";
import { useState } from "react";
import { OwnedObjects } from "./components/UserInfo";
import { GameWindow } from "./components/GameWindow";
import { CreateGame } from "./components/CreateGame";
import { JoinGame } from "./components/JoinGame";

function App() {
  const [game_active, set_game_active] = React.useState(false);
  const [game_id, set_game_id] = React.useState("");

  ///
  return (
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
        <Box>
          <Heading id="name">SHOOTOUT</Heading>
        </Box>

        <Box>
          <ConnectButton />
        </Box>
      </Flex>
      <Container>
        <Container
          mt="5"
          pt="2"
          px="4"
          style={{ background: "var(--gray-a2)", minHeight: 500 }}
        >
          {game_active ? (
            <div> Your game: {game_id} </div>
          ) : (
            <div>
              <CreateGame
                onCreated={(id) => {
                  set_game_id(id);
                  set_game_active(true);
                }}
              />{" "}
              <div>OR</div>
              <JoinGame
                onJoined={(id) => {
                  set_game_id(id);
                  set_game_active(true);
                }}
              />
            </div>
          )}
        </Container>
      </Container>
    </>
  );
}

export default App;
