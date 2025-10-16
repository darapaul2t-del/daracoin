# Daracoin Smart Contract

A comprehensive Clarity smart contract implementing the SIP-010 fungible token standard for the Stacks blockchain. Daracoin (DARA) is a fully-featured cryptocurrency token with advanced administrative controls, minting capabilities, and security features.

## Features

### Core Token Functionality
- **SIP-010 Compliance**: Full implementation of the Stacks Improvement Proposal 010 fungible token standard
- **Token Transfers**: Secure peer-to-peer token transfers with memo support
- **Balance Queries**: Real-time balance checking for any principal
- **Supply Management**: Dynamic total supply tracking

### Administrative Controls
- **Minting System**: Controlled token creation with approved minter management
- **Burning Mechanism**: Token destruction capability for supply reduction
- **Pause/Unpause**: Emergency contract pause functionality
- **Access Control**: Owner-only administrative functions with clear permissions

### Security Features
- **Input Validation**: Comprehensive checks for all user inputs
- **Error Handling**: Detailed error codes for debugging and user feedback
- **Event Logging**: Comprehensive transaction logging for transparency
- **Overflow Protection**: Safe arithmetic operations

## Token Specifications

| Property | Value |
|----------|-------|
| **Name** | Daracoin |
| **Symbol** | DARA |
| **Decimals** | 6 |
| **Initial Supply** | 1,000,000,000 DARA (1 billion tokens) |
| **Total Supply** | Dynamic (can be increased through minting) |

## Smart Contract Functions

### Public Functions

#### Token Operations
- `transfer(amount, from, to, memo)` - Transfer tokens between principals
- `mint(amount, to)` - Mint new tokens (approved minters only)
- `burn(amount, from)` - Burn tokens from caller's balance

#### Administrative Functions
- `add-minter(minter)` - Add a new approved minter (owner only)
- `remove-minter(minter)` - Remove an approved minter (owner only)
- `pause-contract()` - Pause all token operations (owner only)
- `unpause-contract()` - Resume token operations (owner only)

### Read-Only Functions

#### SIP-010 Required Functions
- `get-name()` - Returns token name
- `get-symbol()` - Returns token symbol
- `get-decimals()` - Returns decimal places
- `get-balance(who)` - Returns balance of specified principal
- `get-total-supply()` - Returns current total supply
- `get-token-uri()` - Returns metadata URI

#### Additional Utility Functions
- `is-minter(who)` - Check if principal is approved minter
- `is-paused()` - Check if contract is paused
- `get-owner()` - Returns contract owner

## Error Codes

| Code | Description |
|------|-------------|
| `u100` | Owner only - Caller is not the contract owner |
| `u101` | Not token owner - Caller doesn't own the tokens |
| `u102` | Insufficient balance - Not enough tokens for operation |
| `u103` | Invalid amount - Amount must be greater than 0 |
| `u104` | Transfer failed - Token transfer operation failed |
| `u105` | Mint failed - Token minting operation failed |
| `u106` | Burn failed - Token burning operation failed |
| `u107` | Contract paused - Operations disabled while paused |

## Installation & Setup

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher) - For running tests
- [Stacks CLI](https://docs.stacks.co/build/cli) - For deployment

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <your-repository-url>
   cd daracoin-contract
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Check contract syntax:**
   ```bash
   clarinet check
   ```

4. **Run tests:**
   ```bash
   npm test
   ```

## Development

### Local Testing

Run the test suite:
```bash
clarinet test
```

Run with coverage:
```bash
npm run test:coverage
```

### Contract Validation
```bash
clarinet check
```

### Console Testing
```bash
clarinet console
```

Example console commands:
```clarity
;; Get token info
(contract-call? .daracoin get-name)
(contract-call? .daracoin get-symbol)
(contract-call? .daracoin get-total-supply)

;; Check balance
(contract-call? .daracoin get-balance 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Transfer tokens (as contract owner)
(contract-call? .daracoin transfer u1000000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 none)
```

## Deployment

### Testnet Deployment

1. **Configure your deployment settings:**
   ```bash
   # Edit settings/Testnet.toml with your deployment configuration
   ```

2. **Deploy the contract:**
   ```bash
   clarinet publish --testnet
   ```

### Mainnet Deployment

1. **Configure mainnet settings:**
   ```bash
   # Edit settings/Mainnet.toml with production configuration
   ```

2. **Deploy to mainnet:**
   ```bash
   clarinet publish --mainnet
   ```

## Usage Examples

### Basic Token Operations

```javascript
// Transfer tokens
const transferTx = await contractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'daracoin',
  functionName: 'transfer',
  functionArgs: [
    uintCV(1000000), // 1 DARA (with 6 decimals)
    standardPrincipalCV('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'),
    standardPrincipalCV('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5'),
    noneCV()
  ]
});

// Check balance
const balanceResult = await contractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'daracoin',
  functionName: 'get-balance',
  functionArgs: [
    standardPrincipalCV('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
  ]
});
```

### Administrative Operations

```javascript
// Add a new minter (owner only)
const addMinterTx = await contractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'daracoin',
  functionName: 'add-minter',
  functionArgs: [
    standardPrincipalCV('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')
  ]
});

// Mint new tokens (approved minters only)
const mintTx = await contractCall({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'daracoin',
  functionName: 'mint',
  functionArgs: [
    uintCV(5000000000), // 5000 DARA
    standardPrincipalCV('ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5')
  ]
});
```

## Security Considerations

- **Owner Control**: The contract owner has significant control over minting and pausing. Consider implementing a multi-sig or DAO governance for production use.
- **Minter Management**: Only trusted parties should be added as approved minters.
- **Pause Mechanism**: The pause functionality is for emergency use and should be used responsibly.
- **Input Validation**: All functions include proper input validation, but users should still validate inputs on the frontend.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Include comprehensive tests for new features
- Update documentation for any API changes
- Use descriptive commit messages

## Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
npm test

# Run specific test file
npx vitest tests/daracoin.test.ts

# Run tests in watch mode
npx vitest --watch
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or contributions:

- Create an issue on GitHub
- Join our Discord community
- Email: support@daracoin.io

## Roadmap

- [ ] Multi-signature wallet integration
- [ ] Governance token features
- [ ] Staking mechanisms
- [ ] Bridge to other blockchains
- [ ] DeFi protocol integrations

---

**Disclaimer**: This smart contract is provided as-is. Please conduct thorough testing and auditing before deploying to mainnet with real funds.