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
      <label className="label">
        <input
          type="text"
          value={game_id}
          onChange={(e) => set_game_id(e.target.value)}
          placeholder="Game ID"
          style={{
            width: '100%',
            padding: '10px',
            fontSize: '16px',
            borderRadius: '4px',
            border: '1px solid #ccc'
          }}
        />
      </label>
      <Button className="button" type="submit">
        Join Game
      </Button>
    </form>
  );

  async function joinGame(event) {
    event.preventDefault();
    console.log("joining game id:", game_id);
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
