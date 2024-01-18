#[test_only]
module shootoff::shootoff_tests {
    use shootoff::game::{Self as Game, Game, PlayerTurn, Secret};
    use sui::test_scenario::{Self, Scenario};
    use std::vector;
    use std::hash;

    const NONE: u8 = 0;
    const RELOAD: u8 = 1;
    const SHOOT: u8 = 2;
    const BLOCK: u8 = 3;
    const REFLECT: u8 = 4;
    const KILL_SHOT: u8 = 5;
    const CHEAT: u8 = 111;

    const STATUS_READY: u8 = 0;
    const STATUS_HASH_SUBMISSION: u8 = 1;
    const STATUS_HASHES_SUBMITTED: u8 = 2;
    const STATUS_REVEALING: u8 = 3;
    const STATUS_REVEALED: u8 = 4;

    #[test]
    fun test_block() {
        let player_one = @0x1;
        let player_two = @0x2;

        let scenario_val = test_scenario::begin(player_one);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, player_one);
        Game::new_game(copy player_one, copy player_two, test_scenario::ctx(scenario));

        reload(player_one, scenario);

        let status = reload(player_two, scenario);
        assert!(status == RELOAD, 0);

        test_scenario::next_tx(scenario, player_one);
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &game_val;

            // Assert that player_one's bullets are equal to 1
            assert!(Game::get_player_one_bullets(game) == 1, 0);
            assert!(Game::get_player_two_bullets(game) == 1, 0);
            assert!(Game::get_player_one_lives(game) == 3, 0);
            assert!(Game::get_player_two_lives(game) == 3, 0);

            // Return the game object to the scenario
            test_scenario::return_shared(game_val);
        };

        test_scenario::end(scenario_val);
    }
    
    #[test]
    fun test_shoot() {
        let player_one = @0x1;
        let player_two = @0x2;

        let scenario_val = test_scenario::begin(player_one);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, player_one);
        Game::new_game(copy player_one, copy player_two, test_scenario::ctx(scenario));

        //round 1
        reload(player_one, scenario);
        reload(player_two, scenario);

        //round 2
        let status_one = shoot(player_one, scenario);
        let status_two = reload(player_two, scenario);
        let boo = play(player_one, scenario, status_one, status_two);
        let boo2 = play(player_two, scenario, status_two, status_one);

        if (boo) {
            lose_life(player_two, scenario);
        } else if (boo2) {
            lose_life(player_one, scenario);
        };

        test_scenario::next_tx(scenario, player_one);
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &game_val;
            let kms = &mut game_val;

            // Assert that player_one's bullets are equal to 1
            assert!(Game::get_player_one_bullets(game) == 0, 0);
            assert!(Game::get_player_two_bullets(game) == 2, 0);
            assert!(Game::get_player_one_lives(game) == 3, 0);
            assert!(Game::get_player_two_lives(game) == 2, 0);

            // Return the game object to the scenario
            test_scenario::return_shared(game_val);
        };

        test_scenario::end(scenario_val);
    }

    // #[test]
    // fun test_reload() {
    //     let player_one = @0x1;
    //     let player_two = @0x2;

    //     let scenario_val = test_scenario::begin(player_one);
    //     let scenario = &mut scenario_val;

    //     let s = SHOOT;
    //     let rl = RELOAD;
    //     let b = BLOCK;

    //     // Initialize a new game
    //     test_scenario::next_tx(scenario, player_one);
    //     Game::new_game(player_one, player_two, test_scenario::ctx(scenario));

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));

    //         Game::play(Game::shoot(&mut game, player_one), Game::reload(&mut game, player_two));
    //         let p1_wins = Game::play(s, rl);
    //         let p2_wins = Game::play(rl, s);
    //         if (p1_wins) {
    //             Game::lose_life(&mut game, player_two);
    //         } else if (p2_wins) {
    //             Game::lose_life(&mut game, player_one);
    //         };

    //         Game::play(Game::block(), Game::shoot(&mut game, player_two));
    //         let p1_wins = Game::play(b, s);
    //         let p2_wins = Game::play(s, b);
    //         if (p1_wins) {
    //             Game::lose_life(&mut game, player_two);
    //         } else if (p2_wins) {
    //             Game::lose_life(&mut game, player_one);
    //         };

    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);

    //         assert!(Game::get_player_one_bullets(&game) == 0, 0);
    //         assert!(Game::get_player_two_bullets(&game) == 1, 0);

    //         assert!(Game::get_player_one_lives(&game) == 3, 0);
    //         assert!(Game::get_player_two_lives(&game) == 2, 0);

    //         // Return the game object to the sender
    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::end(scenario_val);
    // }

    // #[test]
    // fun test_overload() {
    //     let player_one = @0x1;
    //     let player_two = @0x2;

    //     let scenario_val = test_scenario::begin(player_one);
    //     let scenario = &mut scenario_val;

    //     let s = SHOOT;
    //     let rl = RELOAD;
    //     let b = BLOCK;
    //     let rf = REFLECT;
    //     let ks = KILL_SHOT;

    //     // Initialize a new game
    //     test_scenario::next_tx(scenario, player_one);
    //     Game::new_game(player_one, player_two, test_scenario::ctx(scenario));

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);
    //         //start
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));

    //         Game::play(Game::kill_shot(&mut game, player_one), Game::shoot(&mut game, player_two));
    //         let p1_wins = Game::play(ks, s);
    //         let p2_wins = Game::play(s, ks);
    //         if (p1_wins) {
    //             Game::lose_life(&mut game, player_two);
    //         } else if (p2_wins) {
    //             Game::lose_life(&mut game, player_one);
    //         };

    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);

    //         assert!(Game::get_player_one_bullets(&game) == 0, 0);
    //         assert!(Game::get_player_two_bullets(&game) == 2, 0);

    //         assert!(Game::get_player_one_lives(&game) == 3, 0);
    //         assert!(Game::get_player_two_lives(&game) == 2, 0);

    //         // Return the game object to the sender
    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::end(scenario_val);
    // }

    // #[test]
    // fun test_reflect_and_kill_shot() {
    //     let player_one = @0x1;
    //     let player_two = @0x2;

    //     let scenario_val = test_scenario::begin(player_one);
    //     let scenario = &mut scenario_val;

    //     let s = SHOOT;
    //     let rl = RELOAD;
    //     let b = BLOCK;
    //     let rf = REFLECT;
    //     let ks = KILL_SHOT;

    //     // Initialize a new game
    //     test_scenario::next_tx(scenario, player_one);
    //     Game::new_game(player_one, player_two, test_scenario::ctx(scenario));

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);
    //         //start
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));

    //         Game::play(Game::shoot(&mut game, player_one), Game::reflect(&mut game, player_two));
    //         let p1_wins = Game::play(s, rf);
    //         let p2_wins = Game::play(rf, s);
    //         if (p1_wins) {
    //             Game::lose_life(&mut game, player_two);
    //         } else if (p2_wins) {
    //             Game::lose_life(&mut game, player_one);
    //         };

    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));
    //         Game::play(Game::reload(&mut game, player_one), Game::reload(&mut game, player_two));

    //         Game::play(Game::block(), Game::kill_shot(&mut game, player_two));
    //         let p1_wins = Game::play(b, ks);
    //         let p2_wins = Game::play(ks, b);
    //         if (p1_wins) {
    //             Game::lose_life(&mut game, player_two);
    //         } else if (p2_wins) {
    //             Game::lose_life(&mut game, player_one);
    //         };

    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);

    //         assert!(Game::get_player_one_bullets(&game) == 3, 0);
    //         assert!(Game::get_player_two_bullets(&game) == 0, 0);

    //         assert!(Game::get_player_one_lives(&game) == 1, 0);
    //         assert!(Game::get_player_two_lives(&game) == 3, 0);

    //         // Return the game object to the sender
    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::end(scenario_val);
    // }

    // #[test]
    // fun test_encryption() {
    //     let player_one = @0x1;
    //     let player_two = @0x2;

    //     let scenario_val = test_scenario::begin(player_one);
    //     let scenario = &mut scenario_val;

    //     test_scenario::next_tx(scenario, player_one);
    //     Game::new_game(player_one, player_two, test_scenario::ctx(scenario));

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let hash = hash(Game::block(), b"secret_salt_1");
    //         Game::player_turn(player_one, hash, test_scenario::ctx(scenario));
    //     };

    //     test_scenario::next_tx(scenario, player_two);
    //     {
    //         let hash = hash(Game::block(), b"secret_salt_2");
    //         Game::player_turn(player_two, hash, test_scenario::ctx(scenario));
    //     };

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);
    //         let cap = test_scenario::take_from_sender<PlayerTurn>(scenario);

    //         assert!(Game::status(&game) == 0, 0);

    //         Game::add_hash(&mut game, cap);

    //         assert!(Game::status(&game) == 1, 0);

    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::next_tx(scenario, player_two);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);
    //         let cap = test_scenario::take_from_sender<PlayerTurn>(scenario);
    //         Game::add_hash(&mut game, cap);

    //         assert!(Game::status(&game) == 2, 0); // STATUS_HASHES_SUBMITTED

    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::next_tx(scenario, player_one);
    //     {
    //         let game = test_scenario::take_from_sender<Game>(scenario);

    //         assert!(Game::get_player_one_lives(&game) == 3, 0);
    //         assert!(Game::get_player_two_lives(&game) == 3, 0);


    //         // Return the game object to the sender
    //         test_scenario::return_to_sender(scenario, game);
    //     };

    //     test_scenario::end(scenario_val);
    // }

    fun reload(
        player: address,
        scenario: &mut Scenario,
    ): u8 {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::reload(game, player);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun shoot(
        player: address,
        scenario: &mut Scenario,
    ): u8 {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::shoot(game, player);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun reflect(
        player: address,
        scenario: &mut Scenario,
    ): u8 {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::reflect(game, player);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun kill_shot(
        player: address,
        scenario: &mut Scenario,
    ): u8 {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::kill_shot(game, player);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun block(
        player: address,
        scenario: &mut Scenario,
    ): u8 {
        // The gameboard is now a shared object.
        // Any player can place a mark on it directly.
        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::block();

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun play(
        player: address,
        scenario: &mut Scenario,
        action_one: u8,
        action_two: u8,
    ): bool {

        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::play(action_one, action_two);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }

    fun lose_life(
        player: address,
        scenario: &mut Scenario,
    ): bool {

        test_scenario::next_tx(scenario, player);
        let status;
        {
            let game_val = test_scenario::take_shared<Game>(scenario);
            let game = &mut game_val;

            status = Game::lose_life(game, player);

            // Return the updated game object to the scenario
            test_scenario::return_shared(game_val);
        };
        status
    }
    
    public fun hash(action: u8, salt: vector<u8>): vector<u8> {
        vector::push_back(&mut salt, action);
        hash::sha2_256(salt)
    }
}