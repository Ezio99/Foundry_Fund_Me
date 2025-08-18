Initialize project -  `forge init`
Run tests - `forge test` 
Run specific test - `forge test --mt <function_name> `


Types of testing
1. Unit
    - Testing a specific part of our code
    - e.g. testMinimumUsd
2. Integration
    - Testing how our code works with other parts of our code
3. Forked -   
   - Testing our code on a simulated real environment
   - e.g.testPriceFeedVersion
4. Staging
    - Testing our code in a real environment that is not prod


To test `testPriceFeedVersion` we provide a fork url
`forge test --mt testPriceFeedVersion -vvvv --fork-url $ALCHEMY_SEPOLIA_RPC_URL`
A fork URL in Foundry is just the RPC endpoint of a blockchain node (mainnet, testnet, or any EVM chain) that Foundry will use to copy the current state of that chain into your local test environment.
It doesnt copy the entire chain, it maintains a connection and when the test calls for an address it it searches for it in the fork chain. (Lazy)

Here's what happens
1. Connects to that node using the provided URL.
2. Downloads the latest block data (or a specific block if you pass --fork-block-number).
3. Creates a local fork — a full simulation of that chain’s state.
4. Runs your tests against that fork.
    - Reads (call operations) are answered from the real chain’s state.
    - Writes (tx operations) happen only locally — they don’t change the real network.


Run `forge coverage --fork-url $ALCHEMY_SEPOLIA_RPC_URL` for code coverage stats (only need fork url if we have tests which need that)

Now that we have mocks setup we can run the usual `forge test`

Foundry also comes with `chisel` which lets us write solidity in terminal

To check how much gas the tests are taking you can run `forge snapshot` or `forge snapshot --mt testWithdrawWithMultipleFunders` for a particular test

One thing to note is, in anvil, by default gas price is 0 so in a test like testWithdrawWithASingleFunder the ending balance matches up to the funds added
without any reduction for gas.
To introduce gas prices we  could use a cheatcode `vm.txGasPrice()` to set a default gas price for a test


Storage in Solidity
Whenever we have global variables or state variables, they are stuck in something called storage slots

The important aspects are the following:
- Each storage has 32 bytes;
- The slots numbering starts from 0;
- Data is stored contiguously starting with the first variable placed in the first slot;
- Dynamically-sized arrays and mappings are treated differently (we'll discuss them below);
- The size of each variable, in bytes, is given by its type;
- If possible, multiple variables < 32 bytes are packed together;
- If not possible, a new slot will be started;
- Immutable and Constant variables are baked right into the bytecode of the contract, thus they don't use storage slots.


`
uint256 var1 = 1337;
uint256 var2 = 9000;
uint64 var3 = 0;
`

How are these stored?

In slot 0 we have var1, in slot 1 we have var2, and in slot 2 we have var 3. Because var 3 only used 8 bytes, we have 24 bytes left in that slot. Let's try another one:

`
uint64 var1 = 1337;
uint128 var2 = 9000;
bool var3 = true;
bool var4 = false;
uint64 var5 = 10000;
address user1 = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
uint128 var6 = 9999;
uint8 var7 = 3;
uint128 var8 = 20000000;
`

How are these stored?

Let's structure them better this time:

slot 0
    var1 8 bytes (8 total)
    var2 16 bytes (24 total)
    var3 1 byte (25 total)
    var4 1 byte (26 total)
    var5 has 8 bytes, it would generate a total of 34 bytes, but we have only 32 so we start the next slot

slot 1
    var5 8 bytes (8 total)
    user1 20 bytes (28 total)
    var6 has 16 bytes, it would generate a total of 44 bytes, we have a max of 32 so we start the next slot

slot2
    var6 16 byes (16 total)
    var7 1 byte (17 total)
    var8 has 16 bytes, it would generate a total of 33 bytes, but as always we have only 32, we start the next slot

slot3
    var8 16 bytes (16 total)

Can you spot the inefficiency? slot 0 has 6 empty bytes, slot 1 has 4 empty bytes, slot 2 has 15 empty bytes, slot 3 has 16 empty bytes. Can you come up with a way to minimize the number of slots?
Mappings and Dynamic Arrays can't be stored in between the state variables as we did above. That's because we don't quite know how many elements they would have. Without knowing that we can't mitigate the risk of overwriting another storage variable. The elements of mappings and dynamic arrays are stored in a different place that's computed using the Keccak-256 hash.Please read more about this here.



https://www.evm.codes/ - A reference of EVM op codes
In the site we can see loading and saving to storage takes a min of 100 gas while loading and saving from memory takes 3.

So a good optimization for gas could be to r/w to memory instead of storage when possible

We optimize withdraw() and create a new function cheaperWithdraw() and this reflects in snapshot as well


Foundry devops - `forge install ChainAccelOrg/foundry-devops`
- Keeps track of latest contract deployment

Ran integration using - `forge test --mt testUserCanInteract -vvvv`

