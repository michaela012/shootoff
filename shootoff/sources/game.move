module shootoff::game {
    // Part 1: Imports
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;
    use std::hash;

    const NONE: u8 = 0;
    const RELOAD: u8 = 1;
    const SHOOT: u8 = 2;
    const BLOCK: u8 = 3;
    const REFLECT: u8 = 4;
    const KILL_SHOT: u8 = 5;
    //const CHEAT: u8 = 111;

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
            id: object::new(ctx),
            lives: 3,
            bullets: 0,
        };
        let player_two_state = Player {
            id: object::new(ctx),
            lives: 3,
            bullets: 0,            
        };

        transfer::transfer(Game {
            id: object::new(ctx),
            prize: PrizePool { id: object::new(ctx) },
            player_one,
            player_two,
            player_one_state: player_one_state,
            player_two_state: player_two_state,
            hash_one: vector[],
            hash_two: vector[],
            gesture_one: NONE,
            gesture_two: NONE,
        }, tx_context::sender(ctx));
    }

    public entry fun round_winner(game: Game, ctx: &TxContext) {
        let Game {
            id,
            prize,
            player_one,
            player_two,
            player_one_state,
            player_two_state,
            hash_one: _,
            hash_two: _,
            gesture_one,
            gesture_two,
        } = game;

        let p1_wins = play(gesture_one, gesture_two);
        let p2_wins = play(gesture_two, gesture_one);

        object::delete(id);

        if (p1_wins) {
            player_two_state.lives = player_two_state.lives - 1;
        } else if (p2_wins) {
            player_one_state.lives = player_one_state.lives - 1;
        };
    }

    public entry fun select_winner(game: Game, ctx: &TxContext) {
        assert!(status(&game) == STATUS_REVEALED, 0);
        //all the other stuff
        let Game {
            id,
            prize,
            player_one,
            player_two,
            player_one_state,
            player_two_state,
            hash_one: _,
            hash_two: _,
            gesture_one,
            gesture_two,
        } = game;

        object::delete(id);

        //decided winner
        if (player_one_state.lives == 0) {
            transfer::public_transfer(prize, player_one)
        } else if (player_two_state.lives == 0) {
            transfer::public_transfer(prize, player_two)
        };
        // else {
        //     contineu
        // };
    }

    fun play(action_one: u8, action_two: u8): bool {
        if (action_one == action_two) { false } //no winner if the actions are the same
        else if (action_one == REFLECT && action_two == SHOOT) { true }
        else if (action_one == REFLECT && action_two == KILL_SHOT) { true}
        else { false } 
    }

    public fun lose_life(player_state: &mut Player) {
        if (player_state.lives > 0) {
            player_state.lives = player_state.lives - 1;
        }
    }

    public fun reload(player_state: &mut Player): u8 {
        if (player_state.bullets < 3) {
            player_state.bullets = player_state.bullets + 1;
            RELOAD 
        } else {
            NONE
        }
    }
    public fun shoot(player_state: &mut Player): u8 {
        if (player_state.bullets > 0) {
            player_state.bullets = player_state.bullets - 1;
            SHOOT
        } else {
            NONE
        }
    }
    public fun block(player_state: &mut Player): u8 {
        BLOCK
    }

    public fun reflect(player_state: &mut Player): u8 {
        if (player_state.bullets > 0) {
            player_state.bullets = player_state.bullets - 1;
            REFLECT
        } else {
            NONE
        }
    }

    public fun kill_shot(player_state: &mut Player): u8 {
        if (player_state.bullets == 3) {
            player_state.bullets = player_state.bullets - 3;
            KILL_SHOT
        } else {
            NONE
        }
    }
    
    fun hash(gesture: u8, salt: vector<u8>): vector<u8> {
        vector::push_back(&mut salt, gesture);
        hash::sha2_256(salt)
    }
}