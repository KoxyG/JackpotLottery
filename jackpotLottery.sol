// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract JackpotLottery {

    address public jackpot;
    address payable[] public players;
    uint public jackpotId;
    mapping (uint => address payable) public jackpotHistory;


    constructor() {
        jackpot = msg.sender;
        jackpotId = 0;
    }

    modifier onlyjackpot() {
        require(msg.sender == jackpot, "only lottery owner that can pick a winner");
        _;
    }

    function enter() external payable {
        require(msg.sender != jackpot, "lottery own can't play");
        require(msg.value > .001 ether, "deposit must be greater than 0.01 ether");

        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns(uint) {
        // hashing algorithm to get random number, keccak256 ruturns byte32
        return uint(keccak256(abi.encodePacked(jackpot, block.timestamp)));
    }

    function pickWinner() external onlyjackpot {
        // calculates the remainder when the random number is divided by the length of the players array.
        require(players.length > 1, "Lottery hasn't started, no participants");
        
        uint index = getRandomNumber() % players.length;
        players[index].transfer(address(this).balance);

        jackpotHistory[jackpotId] = players[index];
        jackpotId++;

        // reset the state of the contract
        players = new address payable[](0);
    }

    function getWinnerByLottery(uint id) external view returns (address payable) {
        return jackpotHistory[id];
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}
