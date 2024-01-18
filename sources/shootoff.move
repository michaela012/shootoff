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
      hash_one: vector[],
      hash_two: vector[],
      player_one_move: NONE,
      player_two_move: NONE,
    });
    
  }

  public fun JoinGame(new_player: address, game: &mut Game, ctx: &mut TxContext) {
    //check new player != player one
    // assert!(new_player != game.player_one, 0);  --> allowing for testing
    //check game not full
    assert!( option::is_none(&game.player_two), 0);

    game.player_two = option::some<address>(new_player);
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
}

  // public fun CheckGameTimeout()

  