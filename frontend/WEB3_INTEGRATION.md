# Web3 Integration Guide for MyModus Flutter App

## Overview

This document describes the Web3 integration in the MyModus Flutter application, including smart contract interaction, wallet connection, and blockchain operations.

## Architecture

The Web3 integration follows a layered architecture:

```
UI Layer (Screens & Widgets)
    ↓
Provider Layer (Web3Provider)
    ↓
Service Layer (Web3Service)
    ↓
Blockchain Layer (web3dart + Smart Contracts)
```

## Components

### 1. Web3Service

The core service for blockchain interactions.

**Location**: `lib/services/web3_service.dart`

**Key Features**:
- Smart contract initialization and management
- Wallet connection and management
- NFT operations (mint, transfer, metadata)
- Loyalty token operations
- Transaction handling
- Network management

**Usage Example**:
```dart
final web3Service = Web3Service();

// Initialize with network
await web3Service.initialize(
  rpcUrl: 'http://127.0.0.1:8545',
  nftContractAddress: '0x...',
  loyaltyContractAddress: '0x...',
);

// Connect wallet
await web3Service.connectWallet(privateKey);

// Mint NFT
final txHash = await web3Service.mintNFT(
  MintNFTRequest(
    to: walletAddress,
    tokenURI: 'ipfs://...',
    name: 'My NFT',
    description: 'Description',
  ),
);
```

### 2. Web3Provider

State management provider for Web3 functionality.

**Location**: `lib/providers/web3_provider.dart`

**Key Features**:
- Wallet connection state
- NFT and token balances
- Transaction history
- Network information
- Error handling

**Usage Example**:
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Web3Provider>(
      builder: (context, web3Provider, child) {
        if (web3Provider.isConnected) {
          return Text('Connected: ${web3Provider.walletAddress}');
        } else {
          return ElevatedButton(
            onPressed: () => web3Provider.connectWallet(),
            child: Text('Connect Wallet'),
          );
        }
      },
    );
  }
}
```

### 3. Web3 Models

Data models for Web3 entities.

**Location**: `lib/models/web3_models.dart`

**Key Models**:
- `NFTModel` - NFT data structure
- `LoyaltyTokenModel` - Loyalty token information
- `UserWalletInfo` - Wallet connection details
- `BlockchainTransaction` - Transaction data
- `NetworkInfo` - Network configuration

### 4. Web3 Configuration

Configuration for networks, contracts, and settings.

**Location**: `lib/config/web3_config.dart`

**Key Configurations**:
- Network definitions (Hardhat, Ganache, Sepolia, Mumbai)
- Contract addresses
- Gas settings
- IPFS configuration
- MetaMask settings

## Smart Contract Integration

### Contract ABI Files

ABI files are stored in `assets/abi/`:
- `MyModusNFT.json` - NFT contract interface
- `MyModusLoyalty.json` - Loyalty token contract interface

### Contract Addresses

Contract addresses are configured in `Web3Config.contractAddresses`:

```dart
static const Map<String, Map<String, String>> contractAddresses = {
  'hardhat': {
    'MyModusNFT': '0x...',
    'MyModusLoyalty': '0x...',
  },
  'sepolia': {
    'MyModusNFT': '0x...',
    'MyModusLoyalty': '0x...',
  },
};
```

**Note**: Update these addresses after deploying contracts to each network.

## Wallet Connection

### Supported Methods

1. **Private Key Connection** (Development)
   ```dart
   await web3Provider.connectWalletWithPrivateKey(privateKey);
   ```

2. **MetaMask Connection** (Production)
   ```dart
   await web3Provider.connectWalletWithMetaMask();
   ```

### Wallet State Management

The `Web3Provider` manages:
- Connection status
- Wallet address
- Network information
- Balance
- Connected contracts

## NFT Operations

### Minting NFTs

```dart
final txHash = await web3Provider.mintNFT(
  name: 'My Fashion NFT',
  description: 'Unique fashion item',
  image: 'ipfs://...',
  attributes: '{"style": "casual", "color": "blue"}',
);
```

### NFT Management

- View owned NFTs
- Transfer NFTs
- Put NFTs for sale
- Buy NFTs from marketplace
- Update metadata

## Loyalty Token Operations

### Token Management

```dart
// Mint loyalty tokens
final txHash = await web3Provider.createLoyaltyToken(
  name: 'MyModus Loyalty',
  symbol: 'MMLT',
  amount: '1000',
);

// Transfer tokens
await web3Provider.transferLoyaltyTokens(
  to: recipientAddress,
  amount: '100',
);
```

### Token Features

- Minting with ETH
- Burning tokens
- Transfer between users
- Balance checking
- User registration

## Network Management

### Supported Networks

1. **Local Development**
   - Hardhat (Chain ID: 31337)
   - Ganache (Chain ID: 1337)

2. **Testnets**
   - Sepolia (Chain ID: 11155111)
   - Mumbai (Chain ID: 80001)

3. **Mainnets**
   - Ethereum (Chain ID: 1)
   - Polygon (Chain ID: 137)

### Network Switching

```dart
// Switch to Sepolia testnet
await web3Provider.switchNetwork('sepolia');

// Get current network info
final network = web3Provider.currentNetwork;
```

## IPFS Integration

### File Upload

```dart
// Upload metadata to IPFS
final ipfsHash = await web3Service.uploadToIPFS(
  metadata: jsonEncode(nftMetadata),
);

// Upload image to IPFS
final imageHash = await web3Service.uploadImageToIPFS(
  imageBytes: imageBytes,
);
```

### IPFS Gateway

Files are accessible via:
- `https://ipfs.io/ipfs/{hash}`
- `https://gateway.pinata.cloud/ipfs/{hash}`
- Custom gateway configuration

## Error Handling

### Common Errors

1. **Network Errors**
   - RPC endpoint unavailable
   - Wrong network connected
   - Gas estimation failed

2. **Contract Errors**
   - Contract not deployed
   - Insufficient permissions
   - Invalid parameters

3. **Wallet Errors**
   - Wallet not connected
   - Insufficient balance
   - User rejected transaction

### Error Handling Example

```dart
try {
  await web3Provider.mintNFT(nftData);
} on Web3Exception catch (e) {
  if (e.code == 'INSUFFICIENT_FUNDS') {
    showError('Insufficient ETH for gas fees');
  } else if (e.code == 'USER_REJECTED') {
    showError('Transaction was rejected by user');
  } else {
    showError('Transaction failed: ${e.message}');
  }
}
```

## Security Considerations

### Private Key Management

- **Development**: Use test private keys
- **Production**: Never store private keys in code
- **User Wallets**: Use MetaMask or WalletConnect

### Contract Security

- Verify contract addresses
- Use only verified contracts
- Implement proper access controls
- Test thoroughly on testnets

### Gas Optimization

- Estimate gas before transactions
- Use appropriate gas limits
- Monitor gas prices
- Implement gas price strategies

## Testing

### Unit Tests

```dart
group('Web3Service Tests', () {
  test('should connect wallet successfully', () async {
    final service = Web3Service();
    await service.connectWallet(testPrivateKey);
    expect(service.isConnected, true);
  });
});
```

### Integration Tests

- Test with local Hardhat network
- Test contract interactions
- Test error scenarios
- Test network switching

### Test Networks

- Use Sepolia for Ethereum testing
- Use Mumbai for Polygon testing
- Use local networks for development

## Deployment

### Environment Configuration

1. **Development**
   ```dart
   // Use local networks
   final network = 'hardhat';
   ```

2. **Staging**
   ```dart
   // Use testnets
   final network = 'sepolia';
   ```

3. **Production**
   ```dart
   // Use mainnets
   final network = 'mainnet';
   ```

### Contract Deployment

1. Deploy contracts to target network
2. Update contract addresses in `Web3Config`
3. Verify contracts on block explorer
4. Update ABI files if needed

## Monitoring and Analytics

### Transaction Monitoring

- Track transaction status
- Monitor gas usage
- Log contract interactions
- Error tracking

### User Analytics

- Wallet connection rates
- Transaction success rates
- Popular NFT types
- Token usage patterns

## Troubleshooting

### Common Issues

1. **"Contract not found"**
   - Check contract address
   - Verify network connection
   - Ensure ABI is correct

2. **"Insufficient funds"**
   - Check wallet balance
   - Verify gas estimation
   - Check token allowances

3. **"Network mismatch"**
   - Switch to correct network
   - Update contract addresses
   - Check chain ID

### Debug Mode

Enable debug logging:

```dart
// In Web3Service
static const bool debugMode = true;

if (debugMode) {
  print('Contract call: ${function.name}');
  print('Parameters: $params');
}
```

## Future Enhancements

### Planned Features

1. **Multi-chain Support**
   - Arbitrum
   - Optimism
   - Base

2. **Advanced Wallet Features**
   - WalletConnect v2
   - RainbowKit integration
   - Social logins

3. **Enhanced NFT Features**
   - Batch minting
   - Royalty management
   - Marketplace integration

4. **DeFi Integration**
   - Staking rewards
   - Liquidity pools
   - Yield farming

## Resources

### Documentation
- [web3dart Documentation](https://pub.dev/packages/web3dart)
- [Ethereum Developer Resources](https://ethereum.org/developers/)
- [Hardhat Documentation](https://hardhat.org/docs)

### Tools
- [MetaMask](https://metamask.io/)
- [Remix IDE](https://remix.ethereum.org/)
- [Etherscan](https://etherscan.io/)
- [IPFS](https://ipfs.io/)

### Community
- [Ethereum Stack Exchange](https://ethereum.stackexchange.com/)
- [Discord Developer Communities](https://discord.gg/ethereum)
- [Reddit r/ethdev](https://reddit.com/r/ethdev)

## Support

For technical support or questions about Web3 integration:

1. Check this documentation
2. Review error logs
3. Test on different networks
4. Consult community resources
5. Contact development team

---

**Last Updated**: August 2024
**Version**: 1.0.0

