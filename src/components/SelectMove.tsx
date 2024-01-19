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
import bullet from '../img/bullet.png';
import red_heart from '../img/red-heart.png';
import blank_heart from '../img/blank-heart.png';
import shoot from '../img/shoot.png';
import block from '../img/block.png';
import reload from '../img/reload.png';
import reflect from '../img/reflect.png';
import killshot from '../img/killshot.png';


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
  const KILL_SHOT = 5;
  return (
    <div className="table-container">
      <table className="custom-table">
        <thead>
          <tr>
            <td colSpan={2}>
              <Button className="button" onClick={() => submitHashedMove(RELOAD, game_id)}>
                <img src={reload} alt="Reload" style={{ height: '2em' }} />
                {"Reload"}
              </Button>
            </td>
          </tr>
        </thead>
        <tbody>
          <tr>
          <td>      
              <Button className="button" onClick={() => submitHashedMove(SHOOT, game_id)}>
              <img src={shoot} alt="Shoot" style={{ height: '2em' }} />
                {"Shoot"}
              </Button>
            </td>
            <td>
              <Button className="button" onClick={() => submitHashedMove(BLOCK, game_id)}>
                <img src={block} alt="Block" style={{ height: '2em' }} />
                {"Block"}
              </Button>
            </td>
          </tr>
          <tr>
            <td>      
              <Button className="button" onClick={() => submitHashedMove(REFLECT, game_id)}>
                <img src={reflect} alt="Reflect" style={{ height: '3em' }} />
                {"Reflect"}
              </Button>
            </td>
            <td>
              <Button className="button" onClick={() => submitHashedMove(KILL_SHOT, game_id)}>
                <img src={killshot} alt="Killshot" style={{ height: '2em' }} />
                {"KillShot"}
              </Button>
            </td>
          </tr>
        </tbody>
      </table>
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
