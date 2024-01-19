### types

- struct PlayerTurn
  - struct for hashed value
- struct Secret
  - salted value player used
- struct Game
  - all game info

### funcs

- public fun NewGame(player, buyin)
  - (p1) starts a game, initializes game data, no players yet joined
- [XX] public fun GetGameInfo(gameUID)
  - (p2) Find the game; gets the buy in value so p2 can confirm to join
- public fun JoinGame(player, gameID)
  - (p2) how player joins game
- public fun SubmitMove()
  - player submits their hashed next move. Logs time.
- public fun GameStatus()
  - sends the current status of what player moves were received (hashes)
- [TEMP] after submitting the move, client loops to check GameStatus. When ready, then prompt to reveal salt.
  If the game times out (other player hasn't submitted), submit no action \_/
- fun CheckGameTimeout()
  - gameStatus calls to see if the current game has timed out (based on time of last move)
- public fun RevealSalt()
  - player sends the salt. On second player submission, round result recorded (game status updated)
- After client reveals, client loops to check whether anyone freezes the game/ stops responding by
  not revealing salt. If not reveal: lose.
- public fun ClaimVictory()

  - if loop running after reveal learns that the opponent hasn't revealed, submitted
    // player is marked the winner and can claim victory

- fun GetMovePlayed(player, )
  - calls hash function to check possible moves, returns the one played (or ends game/ flags cheat)
- fun Hash(salt, possible_move)
  - hashes the possible move using the salt and returns hash
- fun SetHash()
  - set the hash in the game object
- fun DeclareWinner()
  - update the game state after moves have been revealed

// client side

- after getting game info, check it's valid game to join before calling JoinGame
