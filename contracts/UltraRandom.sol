pragma solidity 0.5.0;

import "zos-lib/contracts/Initializable.sol";

contract UltraRandom is Initializable {
    address owner;
    uint once;

    event PendingRando(uint _id1, uint _id2, uint _ready_block, address _asker);

    event RandomOut(uint randomNum, uint usedId1, uint usedId2, uint thisId);

    struct Rando{
            uint id;
            uint randomNum;
            address asker; //the person asking for a random number
            uint ready_block;
            bool pending;
            uint mixWithId;
        }

    uint[] pendingRandos;
    mapping(uint256 => Rando) randos;
    mapping(address => uint) readyRandoms;

    function initialize(uint8 offset1, uint8 offset2) initializer public {

        owner = msg.sender;
        once = 1;

        uint randomSeed1 = uint256(keccak256(abi.encodePacked(
            blockhash(block.number - offset1),
            block.coinbase,
            block.difficulty)));

        uint randomSeed2 = uint256(keccak256(abi.encodePacked(
            blockhash(block.number - offset2),
            block.coinbase,
            block.difficulty)));
        //create the first two randos myself
        Rando memory rando1 = Rando(once, randomSeed1, msg.sender, block.number + offset1, false, 2);
        randos[once] = rando1;
        once = once + 1;
        Rando memory rando2 = Rando(once, randomSeed2, msg.sender, block.number + offset2, false, 1);
        randos[once] = rando2;
        once = once + 1;
    }

    //you want a random number, call this and we'll get back to you in some number of blocks
    //save a reference to a rando that we can get a radnom number from at the ready block
    //same as the breed function in CK
    function putRandom(uint _ready_block_offset, uint id1, uint id2) public payable{
       require(_ready_block_offset > 4); //user input can't be right away. 1 minute average.
       require(msg.value == 0.005 ether); //this fee goes to the rando hunter

        //neither Randos can be waiting
        require(randos[id1].pending == false);
        require(randos[id2].pending == false);

        //this rando is pending.
        //user sets a future block that they agree to use in the random hash
        randos[id1].pending = true;
        randos[id1].mixWithId = id2;
        randos[id1].ready_block = _ready_block_offset + block.number;
        randos[id1].asker = msg.sender;

       //emit pending Randos so its easy findable by the hunters.
       emit PendingRando(id1, id2, randos[id1].ready_block, msg.sender);

    }

    //hunted by rando hunter. Anyone can call this
    //same as the givebirth function in CK
    //set random
    function pullRandom(uint id) public{
        require(randos[id].pending == true); //require that this Rando is waiting to get pulled
        require(randos[id].ready_block <= block.number);//its ready
        require(randos[id].ready_block != 0);
        require(randos[id].mixWithId != 0);

        uint mixedid = randos[id].mixWithId;
        uint newrandom = getRandom(
            once,
            randos[id].randomNum,
            randos[mixedid].randomNum,
            uint256(blockhash(randos[id].ready_block))
          );

        Rando memory instance = Rando(once, newrandom, randos[id].asker, 0, false, 0);
        randos[once] = instance;
        //emit the new random number and the things used to create it.
        emit RandomOut(newrandom, id, mixedid, once);
        once = once + 1;
        //asker (or anyone else) can see the new random number in the new Rando object.

        //TODO return this random somehow
        //pay hunter
        address payable _payto = msg.sender;
        _payto.transfer(0.004 ether);

    }

    function getRandom(uint _once, uint _seed1, uint _seed2, uint _blockhash) internal pure returns(uint256 randomNum){
        return uint256(keccak256(abi.encodePacked(_once, _seed1, _seed2, _blockhash)));//TODO add blockhash
    }

    function cashout(address payable _payto) public {
     require(msg.sender == owner);
     _payto.transfer(address(this).balance);
    }

}
