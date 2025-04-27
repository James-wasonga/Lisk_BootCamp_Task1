// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title LotteryGame
 * @dev A simple number guessing game where players can win ETH prizes
 */
contract LotteryGame {
    struct Player {
        uint256 attempts;
        bool active;
    }

    // TODO: Declare state variables
    // - Mapping for player information
    // - Array to track player addresses
    // - Total prize pool
    // - Array for winners
    // - Array for previous winners

    mapping(address => Player) public players;
    address[] public playerList;
    uint256 public totalPrize;
    address[] public winners;
    address[] public previousWinners;
 
    // TODO: Declare events
    // - PlayerRegistered
    // - GuessResult
    // - PrizesDistributed

    event PlayerRegistered(address indexed player);
    event GuessResult(address indexed player, bool success, uint256 guess, uint256 generatedNumber);
    event PrizesDistributed(address[] winners, uint256 prizePerWinner);

    /**
     * @dev Register to play the game
     * Players must stake exactly 0.02 ETH to participate
     */
    function register() public payable {
        // TODO: Implement registration logic
        // - Verify correct payment amount
        // - Add player to mapping
        // - Add player address to array
        // - Update total prize
        // - Emit registration event

       require(msg.value == 0.02 ether, "Must send exactly 0.02 ETH to register");
        require(!players[msg.sender].active, "Already registered");

        players[msg.sender] = Player({
            attempts: 3,
            active: true
        });

        playerList.push(msg.sender);
        totalPrize += msg.value;

        emit PlayerRegistered(msg.sender);
    }
    

    /**
     * @dev Make a guess between 1 and 9
     * @param guess The player's guess
     */
function guessNumber(uint256 guess) public {
        require(guess >= 1 && guess <= 9, "Guess must be between 1 and 9");
        require(players[msg.sender].active, "Not registered");
        require(players[msg.sender].attempts > 0, "No attempts left");

        uint256 randomNumber = _generateRandomNumber();

        players[msg.sender].attempts -= 1;

        bool success = (guess == randomNumber);
        if (success) {
            winners.push(msg.sender);
            players[msg.sender].active = false;
        } else {
            // Optional: deactivate after all attempts used
            if (players[msg.sender].attempts == 0) {
                players[msg.sender].active = false;
            }
        }

        emit GuessResult(msg.sender, success, guess, randomNumber);
    }
    /**
     * @dev Distribute prizes to winners
     */
    function distributePrizes() public {
        require(winners.length > 0, "No winners to distribute");

        uint256 prizePerWinner = totalPrize / winners.length;

        for (uint256 i = 0; i < winners.length; i++) {
            address winner = winners[i];
            (bool sent, ) = winner.call{value: prizePerWinner}("");
            require(sent, "Failed to send Ether");
            previousWinners.push(winner);
        }

        emit PrizesDistributed(winners, prizePerWinner);

        // Reset state for new round
        delete playerList;
        delete winners;
        totalPrize = 0;
    }

    /**
     * @dev View function to get previous winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() public view returns (address[] memory) {
        return previousWinners;
    }

    /**
     * @dev Helper function to generate a "random" number
     * @return A uint between 1 and 9
     * NOTE: This is not secure for production use!
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 9 + 1;
    }
}
