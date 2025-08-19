
# Foundry_Fund_Me

## Table of Contents

- [Foundry\_Fund\_Me](#foundry_fund_me)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Build](#build)
    - [Test](#test)
    - [Local Testing (Anvil)](#local-testing-anvil)
    - [Deployment](#deployment)
    - [Interaction (Cast)](#interaction-cast)
  - [Folder Structure](#folder-structure)

---

## Overview

This is a minimal project allowing users to fund the contract owner with donations. The smart contract accepts ETH as donations, denominated in USD. Donations have a minimal USD value, otherwise they are rejected. The value is priced using a Chainlink price feed, and the smart contract keeps track of doners in case they are to be rewarded in the future.

---

## Prerequisites

- [Foundry](https://book.getfoundry.sh/) installed (`forge`, `cast`, `anvil`) :contentReference[oaicite:4]{index=4}  
- [Rust](https://www.rust-lang.org) toolchain (optional—only if contributing to Foundry itself)  
- An Ethereum-compatible RPC endpoint (e.g., Alchemy, Infura) for deployment  
- A funded Ethereum account or private key for deployment testing

---

## Installation

Clone the repository and set up:

```bash
git clone https://github.com/Ezio99/Foundry_Fund_Me.git
cd Foundry_Fund_Me
forge install         # (if using submodules or dependencies)
````


---

## Usage

### Build

Compile your smart contracts:

```bash
forge build
```

### Test

Run all tests:

```bash
forge test
```

### Local Testing (Anvil)

Start a local development blockchain:

```bash
anvil
```

### Deployment

Deploy scripts to a Sepolia network:

```bash
make verify-contract-sepolia
```

### Interaction (Cast)

Interact with your deployed contracts:

```bash
cast <subcommand>
```

Try:

```bash
cast call <contract_address> "myFunction(uint256)" 1 --rpc-url <YOUR_RPC_URL>
```



---

## Folder Structure

```text
├── src/                # Solidity source files
├── script/             # Deployment or interaction scripts
├── test/               # Foundry test files
├── lib/                # Optional external libraries
├── .gas-snapshot       # Last gas report
├── foundry.toml        # Foundry project config
├── README.md          
├── Notes.md            # Project or code notes
└── .github/workflows   # CI/CD automations (if any)
```

---

