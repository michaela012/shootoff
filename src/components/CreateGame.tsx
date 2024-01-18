import React from "react";
import { Button, Container, Flex, RadioGroup, Text } from "@radix-ui/themes";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import {
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { useCurrentAccount } from "@mysten/dapp-kit";
import { TESTNET_SHOOTOFF_PACKAGE_ID } from "../constants";
import { useGetGameInfo } from "../getGameInfo";

export function CreateGame({ onCreated }: { onCreated: (id: string) => void }) {
  const client = useSuiClient();
  const account = useCurrentAccount();
  const { mutate: signAndExecuteTransactionBlock } =
    useSignAndExecuteTransactionBlock();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  return (
    <Button className="button" onClick={createNewGame}>
      {" "}
      Start A Game{" "}
    </Button>
  );

  function createNewGame() {
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
        chain: "sui:testnet",
        options: {
          showObjectChanges: true,
          showEffects: true,
        },
      },
      {
        onSuccess: (tx) => {
          console.log(tx);
          client.waitForTransactionBlock({ digest: tx.digest }).then(() => {
            const object_id = tx.effects?.created?.[0]?.reference?.objectId;
            if (object_id) {
              console.log(object_id);
              onCreated(object_id);
            }
          });
        },
        onError: (err) => {
          console.log(err);
        },
      }
    );
  }
}
