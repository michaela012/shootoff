module shootoff::shootoff {
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use std::vector;
  use std::hash;
  use std::address;
  use std::option;

  // -- consts --
  const NONE: u8 = 0;
  const RELOAD: u8 = 1;
  const SHOOT: u8 = 2;
  const BLOCK: u8 = 3;
  const REFLECT: u8 = 4;
  const KILL_SHOT: u8 = 5;
  const CHEAT: u8 = 111;

    const InvalidMove: u8 = 0;

  // game statuses
  const STATUS_READY: u8 = 0;
  const STATUS_HASH_SUBMISSION: u8 = 1;
  const STATUS_HASHES_SUBMITTED: u8 = 2;
  const STATUS_REVEALING: u8 = 3;
  const STATUS_REVEALED: u8 = 4;

  // -- structs --
  // Game struct holds all information about ongoing game.
  struct Game has key {
    id: UID,
    prize: u8,
    player_one: address,
    player_two: option::Option<address>,
    player_one_lives: u8,
    player_one_bullets: u8,
    player_two_lives: u8,
    player_two_bullets: u8,
    hash_one: vector<u8>,
    hash_two: vector<u8>,
    player_one_move: u8,
    player_two_move: u8,
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

  public fun StartNewGame(starting_player: address, buyin: u8, ctx: &mut TxContext) {
    transfer::share_object(Game {
      id: object::new(ctx),
      prize: buyin,
      player_one: starting_player,
      player_two: option::none<address>(),
      player_one_lives: 3,
      player_one_bullets: NONE,
      player_two_lives: NONE,
      player_two_bullets: NONE,
      hash_one: vector[],
      hash_two: vector[],
      player_one_move: NONE,
      player_two_move: NONE,
    });
    
  }

  // public fun JoinGame(player: address, ctx: &mut TxContext) {
  public fun JoinGame(game: &mut Game, new_player: address, ctx: &mut TxContext) {
    //check new player != player one
    // assert!(new_player != game.player_one, 0);  --> allowing for testing
    //check game not full
    // assert!( option::is_none<address>(&game.player_two), 0);
    let optional_addr = option::some<address>(new_player);
    assert!(option::is_some<address>(&optional_addr), 0 );

    game.player_two = optional_addr;
  }

  public fun GameStatus(game: &Game) : u8 {
    let h1_len = vector::length(&game.hash_one);
    let h2_len = vector::length(&game.hash_two);

    if (game.player_one_move != NONE && game.player_two_move != NONE) {
      STATUS_REVEALED
    } else if (game.player_one_move != NONE || game.player_two_move != NONE) {
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

  public fun SubmitHashedMove(game: &mut Game, player: address, hash: vector<u8>) {
    let current_game_status = GameStatus(game);

    assert!(current_game_status == STATUS_HASH_SUBMISSION || current_game_status == STATUS_READY, 0);
    assert!(game.player_one == player || game.player_two == option::some<address>(player), 0);

    if (player == game.player_one && vector::length(&game.hash_one) == 0) {
      game.hash_one = hash;
    } else if (option::some<address>(player) == game.player_two && vector::length(&game.hash_two) == 0) {
      game.hash_two = hash;
    } else {
      abort 0 // unreachable
    };
  }

  public fun SubmitSecret(game: &mut Game, player: address, secret: String){
    let current_game_status = GameStatus(game);

    assert!(current_game_status == STATUS_REVEALING || current_game_status == STATUS_READY, 0);
    assert!(game.player_one == player || game.player_two == option::some<address>(player), 0);

    if (player == game.player_one && game.player_one_move == NONE) {
      game.player_one_move = takeAction(secret, game.hash_one);
    } else if (option::some<address>(player) == game.player_two && game.player_one_move == NONE) {
      game.player_two_move = takeAction(secret, game.hash_two);
    } else {
      abort 0 // unreachable
    };

    if (game.player_one_move != NONE && game.player_two_move != NONE) {
      playRound(game);
      checkForWinner(game, player);
    }
  }

  fun takeAction(game: &mut Game, player_number: u8, salt: vector<u8>): u8 {
    let hash = vector[];
    let player: address = game.player_one;

    if (player_number == 1) {
      hash = game.hash_one;
    } else {
      hash = game.hash_two;
      player = game.player_two;
    }

    if (hash(RELOAD, salt) == *hash) {
      reload(game, player);
    } else if (hash(SHOOT, salt) == *hash) {
      shoot(game, player);
    } else if (hash(BLOCK, salt) == *hash) {
      block(game, player);
    } else if (hash(REFLECT, salt) == *hash) {
      reflect(game, player);
    } else if (hash(KILL_SHOT, salt) == *hash) {
      kill_shot(game, player)
    } else if (hash(NONE, salt) == *hash) {
        NONE
    } else {
        CHEAT
    }
  }

  fun playRound(game) {
    p2_win = playerWinsRound(game.player_one_move, game.player_two_move);
    p2_win = playerWinsRound(game.player_two_move, game.player_one_move);

    if (p1_wins) {
      game.player_two_lives = game.player_two_lives - 1;
    } else if (p2_wins) {
      game.player_one_lives = game.player_one_lives - 1;
    };

  }

  public fun playerWinsRound(p1_move: u8, p2_move: u8): bool {
    if (p1_move == REFLECT && p2_move == SHOOT) { true }
    else if (p1_move == REFLECT && p2_move == KILL_SHOT) { true }
    else if (p1_move == SHOOT && p2_move == RELOAD) { true }
    else if (p1_move == KILL_SHOT && p2_move == RELOAD) { true }
    else if (p1_move == KILL_SHOT && p2_move == SHOOT) { true }
    else if (p1_move == KILL_SHOT && p2_move == BLOCK) { true }
    else { false } 
  }

  fun checkForWinner(game: &mut Game, player) {

  }


  fun reload(game: &mut Game, player: address): u8 {
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

  fun shoot(game: &mut Game, player: address): u8 {
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

  fun reflect(game: &mut Game, player: address): u8 {
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

  fun kill_shot(game: &mut Game, player: address): u8 {
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

  check






//    #[test]
//   public fun test_join_game() {
//     use sui::transfer;

//     let player_one = @0xCAFE;
//     // first transaction to emulate creating game
//     let scenario_val = test_scenario::begin(player_one);
//     let scenario = &mut scenario_val;
//     {
//       StartNewGame(test_scenario::ctx(scenario));
//     };

//     // Check if accessor functions return correct values
//     assert!( &game.player_one==@0xCAFE && &game.player_two==option::none<address>(), 1);

//     // Create a dummy address and transfer the sword
//     let player_two = @0xBAKE;
//     JoinGame()

//     transfer::transfer(sword, dummy_address);
//   }

}

  