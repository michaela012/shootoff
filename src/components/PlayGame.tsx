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
import usercowboy from '../img/user_cowboy.png';
import cowboy from '../img/cowboy.png';
import red_heart from '../img/red-heart.png';
import blank_heart from '../img/blank-heart.png';
import bullet from '../img/bullet.png';


export function PlayGame({ game_id }) {
    const [salt, set_salt] = React.useState("someSalt");

    return (
        
        <div className="table-container">
            <div className="image-container">
                <div>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={usercowboy} alt="User Cowboy" className="user-cowboy-image" />
                    </div>
                
                <div>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={red_heart} alt="heart" className="heart"/>
                    <img src={cowboy} alt="Cowboy" className="cowboy-image" />
                </div>
            </div>
            <SelectMove
                game_id={game_id}
                onSelected={(salt) => {
                    set_salt(salt);
                }}
            />
            <div className="reveal-move">
                <RevealMove game_id={game_id} />
            </div>
        </div>
    );
}
