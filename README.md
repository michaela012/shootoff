# shootoff

Game Rules:
Bullets: -/3

Moves:
Reload - +1 bullets
Shoot - 1 action cost, shoots the other player
Block - 0 action cost, blocks shoot
Reflection - 1 action cost, reflections the shot back if the other player shoots
Kill shot- 3 action cost, pierces through block, pierces through reflection?

Fast paced rounds, decision based game

Visually I imagine it as like a pokemon battle:
5 moves at the bottom, 3 second timer, bullets displayed at the bottom, should you be able to see the other players bullets?

## Setup & Run

- sui docs: https://docs.sui.io/
- sui typescript docs: https://sdk.mystenlabs.com/typescript
- move reference: https://intro.sui-book.com/unit-three/lessons/2_intro_to_generics.html

### Frontend

- `pnpm install` to install dependencies
- `pnpm dev` to run on localhost

### Smart Contract

- set deployment env:
  - `sui client active-env` to check current
  -
- `sui move build` to build
- `sui client publish --gas-budget 100000000 sources/`
  to publish
  - you need gas to publish:
    - `sui client addresses` to find your address
    - ```
      curl --location --request POST 'https://faucet.testnet.sui.io/v1/gas'\
      --header 'Content-Type: application/json' \
      --data-raw '{
        "fixedAmountRequest": {
          "recipient": "<YOUR SUI ADDRESS>"
        }
      }'
      ```
