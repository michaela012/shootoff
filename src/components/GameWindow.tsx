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
import { SelectMove } from "./SelectMove";
import { RevealMove } from "./RevealMove";
import { useGetGameInfo } from "../getGameInfo";

export function GameWindow({ game_id }) {
  const { getGameInfo } = useGetGameInfo();
  const { data, isLoading, error, refetch } = getGameInfo(game_id);
  const [salt, set_salt] = React.useState("someSalt");
  // game states
  const GAME_STATES = {
    ENTER_MOVE: 1,
    WAIT_FOR_OP_MOVE: 2,
    REVEAL_MOVE: 3,
    WAIT_FOR_OP_REVEAL: 4,
    LOST_GAME: 5,
    WON_GAME: 6,
  };
  const [game_state, set_game_state] = React.useState(0);
  const account = useCurrentAccount();
  const account_address = account?.address as string;
  if (!account_address) {
    return null;
  }

  useEffect(() => {
    const interval = setInterval(() => {
      refetch();
      console.log(interval);
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!isLoading && !error && data?.data) {
      const game_data = getGameData(data.data);
      const game_state = getGameState(game_data, account_address, GAME_STATES);
      set_game_state(game_state);
    }
  }, [data, isLoading, error]);

  return (
    <div>
      <SelectMove
        game_id={game_id}
        onSelected={(salt) => {
          set_salt(salt);
        }}
      />
      <RevealMove game_id={game_id} salt={salt} />
    </div>
  );
}

function getGameData(data: SuiObjectData) {
  if (data.content?.dataType !== "moveObject") {
    throw new Error("Content not found");
  }

  const game_data = data.content.fields;
  console.log(game_data);
  return game_data;
}

function getGameState(game_data, account_address, states) {
  if (
    game_data.player_one != account_address &&
    game_data.player_two != account_address
  ) {
    console.error("Do you even go here?");
    return Error("invalid player address");
  }

  let hash, op_hash, move, op_move, lives, op_lives;
  if (game_data.player_one == account_address) {
    hash = game_data.hash_one;
    op_hash = game_data.hash_two;
    move = game_data.player_one_move;
    op_move = game_data.player_two_move;
    lives = game_data.player_one_lives;
    op_lives = game_data.player_two_lives;
  } else if (game_data.player_two == account_address) {
    hash = game_data.hash_two;
    op_hash = game_data.hash_one;
    move = game_data.player_two_move;
    op_move = game_data.player_one_move;
    lives = game_data.player_two_lives;
    op_lives = game_data.player_one_lives;
  }

  if (!hash) {
    return states.ENTER_MOVE;
  }
  if (!op_hash) {
    return states.WAIT_FOR_OP_MOVE;
  }
  if (!move) {
    return states.REVEAL_MOVE;
  }
  if (!op_move) {
    return states.WAIT_FOR_OP_REVEAL;
  }
  if (lives == 0) {
    return states.LOST_GAME;
  }
  if (op_lives == 0) {
    return states.WON_GAME;
  }
}
