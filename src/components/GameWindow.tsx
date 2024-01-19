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

export function GameWindow({ game_id }) {
  const [salt, set_salt] = React.useState("someSalt");

  return (
    <div>
      <SelectMove
        game_id={game_id}
        onSelected={(salt) => {
          set_salt(salt);
        }}
      />
      <RevealMove game_id={game_id} />
    </div>
  );
}
