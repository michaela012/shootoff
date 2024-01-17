import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";
import { isValidSuiObjectId } from "@mysten/sui.js/utils";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import React from "react";
import { useState } from "react";
import { OwnedObjects } from "./components/UserInfo";
import { GameWindow } from "./components/GameWindow";

function App() {
  const currentAccount = useCurrentAccount();
  // const [counterId, setCounter] = useState(() => {
  //   const hash = window.location.hash.slice(1);
  //   return isValidSuiObjectId(hash) ? hash : null;
  // });

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
          <Heading>SHOOTOUT</Heading>
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
          <OwnedObjects />
          <GameWindow />
        </Container>
      </Container>
    </>
  );
}

export default App;
