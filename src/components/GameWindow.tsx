import React, { useState, useEffect } from "react";
import { Button, Container, Flex, RadioGroup, Text } from "@radix-ui/themes";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import {
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { SuiObjectData } from "@mysten/sui.js/client";
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { TESTNET_SHOOTOFF_PACKAGE_ID } from "../constants";

export function GameWindow() {
  const client = useSuiClient();
  const account = useCurrentAccount();
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  async function createNewGame() {
    let transactionBlock = new TransactionBlock();
    transactionBlock.moveCall({
      target: `${TESTNET_SHOOTOFF_PACKAGE_ID}::shootoff::StartNewGame`,
      arguments: [
        transactionBlock.pure(account_address), //player account address
        transactionBlock.pure("1"), //buyin
      ],
    });
    signAndExecuteTransactionBlock(
      {
        transactionBlock,
        chain: "sui:testnet", //TODO: update
      },
      {
        onSuccess: (tx) => {
          console.log(tx);
          // client.waitForTransactionBlock({ digest: tx.digest }).then(() => {
          //   refetch();
          // });
        },
        onError: (err) => {
          console.log(err);
        },
      }
    );
  }
  return (
    <div>
      <Container>
        <Button onClick={createNewGame}> CreateNewGame </Button>
      </Container>
    </div>
  );
}
