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
import { hash } from "../hashMove";

export function RevealMove({ game_id }) {
  const [salt, setSalt] = React.useState("someSalt");
  const client = useSuiClient();
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();
  const account = useCurrentAccount();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  return (
    <div>
      <Button className="button" onClick={() => revealMove(game_id, salt)}>
        {"Reflect"}
      </Button>
    </div>
  );

  async function revealMove(game_id, salt) {
    let transactionBlock = new TransactionBlock();
    transactionBlock.moveCall({
      target: `${TESTNET_SHOOTOFF_PACKAGE_ID}::shootoff::SubmitSecret`,
      arguments: [
        transactionBlock.object(game_id),
        transactionBlock.pure(account_address), //player account address
        transactionBlock.pure(salt),
      ],
    });
    signAndExecuteTransactionBlock(
      {
        transactionBlock,
        chain: "sui:testnet",
        options: {
          showObjectChanges: true,
          showEffects: true,
        },
      },
      {
        onSuccess: (tx) => {
          console.log(tx);
          // onSelected(game_id);
        },
        onError: (err) => {
          console.log(err);
        },
      }
    );
  }
}
