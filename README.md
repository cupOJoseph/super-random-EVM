# superRandom
EVM library for easily accessing varying levels of randomness.

Only supports Rinkeby for now.

## Goals
Create an easy way to get random numbers on chain without having to rely on third party oracles. Provide varying degrees of randomness to meet a user's needs.

### Why an EVM package?
Why not a library like safemath? In order to do Ultra and better levels of randomnes onchain some kind of state must be stored. It is impossible to have that high level of randomness from pure functions. We must use a future hash that can't be predicted in our request for random numbers, so some kind of timer system must be used & stored.

## Installation
Requires a recent version of nodejs and npm. This package is published with Zeppelin OS
```
npm install zos
npx zos link super-random-evm
```

## Decent
DecentRandom.sol is a standalone pseudo random generating tool. It's randomness is decent, but could be slightly influenced by the miner of the block when random numbers are generated.  The Decent random getter should not be used if any significant amount of value is on the line, but it will be good for many simple uses.

### Use
Using the Decent random functions is easy. There are 2 main ways to intereact with the Rinkeby deployment, which is deployed here:

1. Get a random uint256: call the `getRandom()` function on DecentRanom.
2. Get a random uint256 between 0 and some max number: call the `getRandomLimit(maxnumber)` function.

You can test these on Rinkeby manually here: https://oneclickdapp.com/eric-nurse

## Ultra
Use of Ultra is more complicated but results in *much* more random numbers. The Ultra contract is an ownerless clone of the cryptokitties breeding algorithm, but without kitties. It requires the user asking for a random number to choose a future block. Later, during or after that block is mined, the unpredictable hash of the chosen block is used in conjunction with other previously generated random numbers to generate a new random uint256 via another hash.

### Use
There is a new Rando object, similar to a crypto-collectible like cryptokitties, but without ownership. They are used to generate a new random number. Each has a unique ID, a random uint, a check to see if it is pending being used, and some other data.

First, to request a new random number from Ultra call the `putRandom(...)` function.  The function takes three parameters and sets up a random number generation at a later time instead of immediately returning one. The parameters are:
1. A future block number, at least 5 from now. You can get this this by doing something like `uint futureblock = block.number + 5`.
2. An ID for any Rando object with is not pending. The corresponding Rando object for that that ID will be set to pending.
3. The ID for a second Rando object, the attributes of which will be used in the hash to create a new random number but will not be set to pending.

Second, we all wait until the future block selected has passed.

Thirdly, anyone can call the `pullRandom()` function to generate a new Rando object with a new random number affiliated with it. The function takes the ID of a Rando object that is both pending, and which has been waiting at least the specified number of blocks.

Because we need to call the `pullRandom()` function later, we need to give an incentive to "random hunters" to spend their time and gas on calling the function as soon as possible. It won't work if it's called after 256 blocks of being ready. So `putRandom()` requires a small 0.005 ETH payment, which goes to whoever calls `pullRandom()` successfully.
