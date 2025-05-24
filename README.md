# 🖼️ NFT Membership Card

**NFT Membership Card** is a fully-tested ERC721 smart contract built with Foundry. It features a secure minting process using Merkle Tree whitelist verification, NFT staking with transfer locking, and a random staker selection mechanism suitable for raffles or rewards.

> **Note**
> Built with OpenZeppelin Contracts v5.3.0 and tested using Foundry. Full 100% test coverage achieved.

---

## 🔹 Key Features

* ✅ ERC721 minting with Merkle Tree whitelist verification.
* ✅ Transfer-blocking NFT staking system.
* ✅ Random staker selection (pseudo-random on-chain).
* ✅ Fully integrated fuzzing tests.
* ✅ 100% test coverage using `forge coverage`.

---

## 🖉 Contract Flow Diagram

![Membership Flow Diagram](diagrams/membership_flow.png)

---

## 📄 Deployed Contract

| 🔧 Item                    | 📋 Description                                                          |
| -------------------------- | ----------------------------------------------------------------------- |
| **Contract Name**          | `MembershipCard`                                                        |
| **Deployed Network**       | — (to be deployed)                                                      |
| **Contract Address**       | —                                                                       |
| **Verified on Explorer**   | ✅ Pending                                                               |
| **Constructor Parameters** | `string name`, `string symbol`, `uint256 totalSupply`, `string baseUri` |

---

## 🚀 How to Use Locally

### 1️⃣ Clone and Set Up

```bash
git clone https://github.com/youruser/nft-membership-card.git
cd nft-membership-card
```

### 2️⃣ Install Dependencies

```bash
forge install
npm install
```

### 3️⃣ Generate Merkle Tree

```bash
npx tsx script/generateMerkleTree.ts
```

### 4️⃣ Run Tests

```bash
forge test -vvvv
```

### 5️⃣ Check Coverage

```bash
forge coverage
```

---

## 🧠 Project Structure

```
nft-membership-card/
├── diagrams/                      # Flowcharts and visuals
├── lib/                           # OpenZeppelin and dependencies
├── script/
│   └── generateMerkleTree.ts     # Script to generate whitelist Merkle Tree
├── src/
│   └── MembershipCard.sol        # Main ERC721 smart contract
├── test/                         # Foundry unit tests
│   ├── MembershipCardWhitelistTest.t.sol
│   ├── MembershipCardStakingTest.t.sol
│   └── MembershipCardRaffleTest.t.sol
├── foundry.toml                  # Foundry config
└── README.md                     # Project documentation
```

---

## 🔍 Contract Summary

### Functions

| Function                   | Description                                               |
| -------------------------- | --------------------------------------------------------- |
| `constructor(...)`         | Initializes name, symbol, baseURI, and total supply       |
| `mintWhitelist(bytes32[])` | Allows whitelisted addresses to mint NFT via Merkle proof |
| `stake(uint256)`           | Locks an NFT by staking it                                |
| `unstake(uint256)`         | Unlocks a staked NFT                                      |
| `pickRandomStakerWinner()` | Picks a random address from active stakers                |

---

## 🧪 Tests

The project includes a complete suite of unit and fuzzing tests:

* ✅ Minting with and without whitelist
* ✅ Staking and unstaking behavior
* ✅ Transfer blocking while staked
* ✅ Fuzzed inputs on `mintWhitelist()` and `stake()`
* ✅ Raffle logic for random winner selection

---

## 📊 Test Coverage

| File                     | % Lines  | % Statements | % Branches | % Functions |
| ------------------------ | -------- | ------------ | ---------- | ----------- |
| `src/MembershipCard.sol` | 100.00%  | 100.00%      | 100.00%    | 100.00%     |
| `test/*.t.sol`           | 100.00%  | 100.00%      | 100.00%    | 100.00%     |
| **Total**                | **100%** | **100%**     | **100%**   | **100%**    |

> Generated with `forge coverage` using Solidity 0.8.28

---

## 📜 License

This project is licensed under the MIT License.

---

### 🛠 NFT Membership Card — A practical foundation for secure, stakable, and gamified NFTs.
