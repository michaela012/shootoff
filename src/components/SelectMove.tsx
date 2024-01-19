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

export function SelectMove({
  game_id,
  onSelected,
}: {
  game_id;
  onSelected: (salt: string) => void;
}) {
  const client = useSuiClient();
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();
  const account = useCurrentAccount();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  const RELOAD = 1;
  const SHOOT = 2;
  const BLOCK = 3;
  const REFLECT = 4;
  return (
    <div>
      <Button
        className="button"
        onClick={() => submitHashedMove(RELOAD, game_id)}
      >
        {"Reload"}
      </Button>
      <Button
        className="button"
        onClick={() => submitHashedMove(SHOOT, game_id)}
      >
        {"Shoot"}
      </Button>
      <Button
        className="button"
        onClick={() => submitHashedMove(BLOCK, game_id)}
      >
        {"Block"}
      </Button>
      <Button
        className="button"
        onClick={() => submitHashedMove(REFLECT, game_id)}
      >
        {"Reflect"}
      </Button>
    </div>
  );

  async function submitHashedMove(move, game_id) {
    console.log("in submitHashedMove onclick, move:", move);

    let salt = crypto.getRandomValues(new Uint8Array(10)).toString();
    let hashed_move = hash(move, salt);
    let transactionBlock = new TransactionBlock();
    transactionBlock.moveCall({
      target: `${TESTNET_SHOOTOFF_PACKAGE_ID}::shootoff::SubmitHashedMove`,
      arguments: [
        transactionBlock.object(game_id),
        transactionBlock.pure(account_address), //player account address
        transactionBlock.pure(hashed_move),
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
          onSelected(salt);
        },
        onError: (err) => {
          console.log(err);
        },
      }
    );
  }
}
