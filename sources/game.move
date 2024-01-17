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

    const InvalidMove: u8 = 0;

    //Game status
    const STATUS_READY: u8 = 0;
    const STATUS_HASH_SUBMISSION: u8 = 1;
    const STATUS_HASHES_SUBMITTED: u8 = 2;
    const STATUS_REVEALING: u8 = 3;
    const STATUS_REVEALED: u8 = 4;

    struct PrizePool has key, store {
        id: UID
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
        player_one_lives: u64,
        player_one_bullets: u64,
        player_two_lives: u64,
        player_two_bullets: u64,
        hash_one: vector<u8>,
        hash_two: vector<u8>,
        action_one: u8,
        action_two: u8,
    }

    public fun status(game: &Game): u8 {
        let h1_len = vector::length(&game.hash_one);
        let h2_len = vector::length(&game.hash_two);

        if (game.action_one != NONE && game.action_two != NONE) {
            STATUS_REVEALED
        } else if (game.action_one != NONE || game.action_two != NONE) {
            STATUS_REVEALING
        } else if (h1_len == 0 && h2_len == 0) {
            STATUS_READY
        } else if (h1_len != 0 && h2_len != 0) {
            STATUS_HASHES_SUBMITTED
        } else if (h1_len != 0 || h2_len != 0) {
            STATUS_HASH_SUBMISSION
        } else {
            0
        }
    }

    public entry fun new_game(player_one: address, player_two: address, ctx: &mut TxContext) {
        transfer::transfer(Game {
            id: object::new(ctx),
            prize: PrizePool { id: object::new(ctx) },
            player_one,
            player_two,
            player_one_lives: 3,
            player_one_bullets: 0,
            player_two_lives: 3,
            player_two_bullets: 0,
            hash_one: vector[],
            hash_two: vector[],
            action_one: NONE,
            action_two: NONE,
        }, tx_context::sender(ctx));
    }

    public entry fun select_winner(game: Game) {
        let Game {
            id,
            prize,
            player_one,
            player_two,
            player_one_lives,
            player_one_bullets:_,
            player_two_lives,
            player_two_bullets:_,
            hash_one: _,
            hash_two: _,
            action_one,
            action_two,
        } = game;

        while (player_one_lives > 0 && player_two_lives > 0) {
            let p1_wins = play(action_one, action_two);
            let p2_wins = play(action_two, action_one);

            if (p1_wins) {
                player_two_lives = player_two_lives - 1;
            } else if (p2_wins) {
                player_one_lives = player_one_lives - 1;
            };
        };

        let winner: address;

        if (player_two_lives == 0) {
            winner = player_one;
        } else if (player_one_lives == 0) {
            winner = player_two;
        } else {
            abort 0;
        };

        transfer::public_transfer(prize, winner);

        object::delete(id);
    }

    fun play(action_one: u8, action_two: u8): bool {
        if (action_one == action_two) { false } //no winner if the actions are the same
        else if (action_one == REFLECT && action_two == SHOOT) { true }
        else if (action_one == REFLECT && action_two == KILL_SHOT) { true}
        else { false } 
    }

    public fun lose_life(game: &mut Game, player: address) {
        if (player == game.player_one && game.player_one_lives > 0) {
            game.player_one_lives = game.player_one_lives - 1;
        } else if (player == game.player_two && game.player_two_lives > 0) {
            game.player_two_lives = game.player_two_lives - 1;
        }
    }

    public fun reload(game: &mut Game, player: address): u8 {
        if (player == game.player_one && game.player_one_bullets < 3) {
            game.player_one_bullets = game.player_one_bullets + 1;
            RELOAD 
        } else if (player == game.player_two && game.player_two_bullets < 3) {
            game.player_two_bullets = game.player_two_bullets + 1;
            RELOAD 
        } else {
            InvalidMove
        }
    }
    public fun shoot(game: &mut Game, player: address): u8 {
        if (player == game.player_one && game.player_one_bullets > 0) {
            game.player_one_bullets = game.player_one_bullets - 1;
            SHOOT 
        } else if (player == game.player_two && game.player_two_bullets > 0) {
            game.player_two_bullets = game.player_two_bullets - 1;
            SHOOT 
        } else {
            InvalidMove
        }
    }
    public fun block(): u8 {
        BLOCK
    }

    public fun reflect(game: &mut Game, player: address): u8 {
        if (player == game.player_one && game.player_one_bullets > 0) {
            game.player_one_bullets = game.player_one_bullets - 1;
            REFLECT 
        } else if (player == game.player_two && game.player_two_bullets > 0) {
            game.player_two_bullets = game.player_two_bullets - 1;
            REFLECT 
        } else {
            InvalidMove
        }
    }

    public fun kill_shot(game: &mut Game, player: address): u8 {
        if (player == game.player_one && game.player_one_bullets == 3) {
            game.player_one_bullets = game.player_one_bullets - 3;
            KILL_SHOT 
        } else if (player == game.player_two && game.player_two_bullets == 3) {
            game.player_two_bullets = game.player_two_bullets - 3;
            KILL_SHOT 
        } else {
            InvalidMove
        }
    }
    
    fun hash(gesture: u8, salt: vector<u8>): vector<u8> {
        vector::push_back(&mut salt, gesture);
        hash::sha2_256(salt)
    }
}