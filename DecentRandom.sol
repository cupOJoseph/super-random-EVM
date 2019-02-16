pragma solidity 0.5.0;

contract DecentRandom{
    address owner;
    uint256 randomSeed;
    
    constructor() public{
        owner = msg.sender;
        
        randomSeed = uint256(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.coinbase,
            block.difficulty)));
    }
    
    //Return a decent random uint256 
    function getRandom() public returns(uint256 decentRandom ){
        randomSeed = uint256(keccak256(abi.encodePacked(
            randomSeed,
            blockhash(block.number - ((randomSeed % 63) + 1)), //must choose at least 1 block before this one.
            block.coinbase,
            block.difficulty)));
        return randomSeed;
    }

    //get a random number within a limit
    function getRandomLimit(uint limit) public returns (uint256 decentRandom){
        return getRandom() % limit;
    }
    
    //dont send ETH to this address, but in case you do we can cashout.
    function cashout(address payable _payto) public {
     require(msg.sender == owner);
     _payto.transfer(address(this).balance);
    }
}
