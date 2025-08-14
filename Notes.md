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