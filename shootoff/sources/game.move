module shootoff::game {
    // Part 1: Imports
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;
    use std::hash;

    const RELOAD: u8 = 0;
    const SHOOT: u8 = 1;
    const BLOCK: u8 = 2;
    const REFLECT: u8 = 3;
    //const CHEAT: u8 = 111;

    public fun reload(): u8 { RELOAD }
    public fun shoot(): u8 { SHOOT }
    public fun block(): u8 { BLOCK }
    public fun reflect(): u8 { REFLECT }

    //Game status

    struct PrizePool has key, store {
        id: UID
    }

    struct Player has key, store {
        id: UID,
        lives: u64,
        bullets: u64,
    }

    struct PlayerTurn has key {
        id: UID,
        hash: vector<u8>,
        player: address,
    }

    struct Secret has key {
        id: UID,
        salt: vector<u8>,
        player: address,
    }

    struct Game has key {
        id: UID,
        prize: PrizePool,
        player_one: address,
        player_two: address,
        player_one_state: Player,
        player_two_state: Player,
        hash_one: vector<u8>,
        hash_two: vector<u8>,
        gesture_one: u8,
        gesture_two: u8,
    }

    // fun init(ctx: &mut TxContext)

    public entry fun new_game(player_one: address, player_two: address, ctx: &mut TxContext) {
        let player_one_state = Player {
            lives: 3,
            bullets: 0,
        }
        let player_one_state = Player {
            lives: 3,
            bullets: 0,            
        }
        transfer::transfer(Game {
            id: object::new(ctx),
            prize: PrizePool { id: object::new(ctx) },
            player_one,
            player_two,
            player_one_state: player_one_state,
            player_two_state: player_two_state,
        }, tx_context::sender(ctx));
    }

    

    public fun lose_life(player_state: &mut Player) {
        if (player_state.lives > 0) {
            player_state.lives = player_state.lives - 1;
        } 
    }
    
}