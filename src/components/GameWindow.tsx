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
  const [game_active, set_game_active] = React.useState(false);
  const [game_id, set_game_id] = React.useState("");
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
              set_game_active(true);
              set_game_id(object_id);
            }
          });
        },
        onError: (err) => {
          console.log(err);
        },
      }
    );
  }

  async function joinGame(game_id) {
    console.log("join game function, game id:", game_id);
    let transactionBlock = new TransactionBlock();
    transactionBlock.moveCall({
      target: `${TESTNET_SHOOTOFF_PACKAGE_ID}::shootoff::JoinGame`,
      arguments: [
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
          client.waitForTransactionBlock({ digest: tx.digest }).then(() => {
            const object_id = tx.effects?.created?.[0]?.reference?.objectId;
            if (object_id) {
              console.log(object_id);
              set_game_active(true);
              set_game_id(object_id);
            }
          });
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
        <div>
          {game_active ? (
            <CurrentGame game_id={game_id} />
          ) : (
            <div>
              <Button onClick={createNewGame}> Start A Game </Button>
              <JoinGame joinGame={joinGame} />
            </div>
          )}
        </div>
      </Container>
    </div>
  );
}

function CurrentGame({ game_id }) {
  return (
    <body>
      <p> game code (share with a friend!): {game_id} </p>
    </body>
  );
}

function JoinGame({ joinGame }) {
  return (
    <div>
      <p> To join a game, enter an ID. </p>
      <JoinGameForm joinGame={joinGame} />;
    </div>
  );
}

class JoinGameForm extends React.Component<{}, { value: string }> {
  constructor(props) {
    super(props);
    this.state = { value: "" };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({ value: event.target.value });
  }

  handleSubmit(event) {
    this.props.joinGame(this.state.value);
    event.preventDefault();
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Game ID:
          <input
            type="text"
            value={this.state.value}
            onChange={this.handleChange}
          />
        </label>
        <Button type="submit" value="Join Game">
          Join Game
        </Button>
      </form>
    );
  }
}
