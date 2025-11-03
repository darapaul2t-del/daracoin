# darabit

A simple OTC escrow smart contract written in Clarity for trading a SIP-010 fungible token (e.g., DARA) for STX. Sellers escrow tokens into the contract, set a fixed STX price, and buyers can accept the offer in a single atomic transaction.

This project includes the Daracoin token contract and the Darabit marketplace contract. Darabit calls the local `daracoin` contract for token transfers.

## Contracts
- Token: `daracoin-contract/contracts/daracoin.clar` (registered as `contracts.daracoin`)
- Marketplace: `contracts/darabit.clar` (registered as `contracts.darabit`)

### Public functions (darabit)
- `create-offer(amount uint, price uint) -> (response uint uint)`
  - Escrows `amount` DARA tokens from caller to Darabit and creates an offer priced in micro-STX. Returns the new `offer-id`.
- `cancel-offer(id uint) -> (response bool uint)`
  - Seller-only. Returns escrowed tokens and deletes the offer if not yet filled.
- `accept-offer(id uint) -> (response bool uint)`
  - Buyer pays `price` micro-STX to seller; contract releases escrowed tokens to buyer.

### Read-only helpers
- `get-last-offer-id()`
- `get-offer(id)` -> optional tuple

### Error codes
- `u100` not owner
- `u101` already initialized
- `u102` not initialized
- `u200` offer not found
- `u201` not seller
- `u202` already filled
- `u300` FT transfer error
- `u301` STX transfer error

## Quickstart with Clarinet
1) Install Clarinet (https://docs.hiro.so/clarinet/getting-started)
2) Check the project:
   - `clarinet check`
3) Start a console:
   - `clarinet console`
4) Create an offer (escrows DARA into Darabit):
   - `(contract-call? .darabit create-offer u1000000 u5000000)`
     - Example: sell 1,000,000 base units for 5,000,000 micro-STX (5 STX).
5) Accept from a different wallet:
   - `(contract-call? .darabit accept-offer u1)`
6) Cancel an unfilled offer as the seller:
   - `(contract-call? .darabit cancel-offer u1)`

Notes:
- Prices are specified in micro-STX.
- Darabit assumes the local `daracoin` contract exposes `transfer(amount, from, to, memo)` compatible with SIP-010.
