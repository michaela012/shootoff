import React, { useState, useEffect } from "react";
import { Button, Container, Flex, RadioGroup, Text } from "@radix-ui/themes";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import {
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { TESTNET_SHOOTOFF_PACKAGE_ID } from "../constants";

export function JoinGame({ onJoined }: { onJoined: (id: string) => void }) {
  const client = useSuiClient();
  const account = useCurrentAccount();
  const [game_id, set_game_id] = useState("");
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  return (
    <form onSubmit={joinGame}>
      <label>
        Join with game ID:
        <input
          type="text"
          value={game_id}
          onChange={(e) => set_game_id(e.target.value)}
        />
      </label>
      <Button type="submit"> Join Game </Button>
    </form>
  );

  async function joinGame(event) {
    event.preventDefault();
    console.log("join game function, game id:", game_id);
    console.log("account_address", account_address);
    // const { getGameInfo } = useGetGameInfo();
    // const { data, isLoading, error, refetch } = getGameInfo(game_id);

    let transactionBlock = new TransactionBlock();
    transactionBlock.moveCall({
      target: `${TESTNET_SHOOTOFF_PACKAGE_ID}::shootoff::JoinGame`,
      arguments: [
        transactionBlock.object(game_id),
        transactionBlock.pure(account_address), //player account address
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
          onJoined(game_id);
          //TODO: what does this do
          // client.waitForTransactionBlock({ digest: tx.digest }).then(() => {
          //   refetch();
          // });
        },
        onError: (err) => {
          console.log("error");
          console.log(err);
        },
      }
    );
  }
}
