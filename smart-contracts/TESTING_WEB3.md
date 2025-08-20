# Testing Web3 Integration for MyModus

This document provides instructions for testing the Web3 integration without deploying actual smart contracts.

## Overview

We've created mock smart contracts and updated the frontend configuration to use mock addresses for testing purposes. This allows you to test the Web3 functionality without needing to deploy contracts to a testnet.

## Mock Contract Addresses

The following mock addresses are configured in `frontend/lib/config/web3_config.dart`:

- **MyModusNFT**: `0x1234567890123456789012345678901234567890`
- **MyModusLoyalty**: `0x0987654321098765432109876543210987654321`

## Testing Steps

### 1. Frontend Testing

1. **Build and run the Flutter app**:
   ```bash
   cd frontend
   flutter run
   ```

2. **Navigate to Web3 Screen**:
   - Login/Register in the app
   - Go to the Web3 tab in the bottom navigation
   - Test wallet connection functionality

3. **Test NFT Features**:
   - Try to mint an NFT (will show mock transaction)
   - View NFT grid (will show mock data)
   - Test putting NFTs for sale

4. **Test Loyalty Tokens**:
   - Create loyalty tokens
   - View token balance
   - Test token transfers

### 2. Backend Testing

1. **Start the backend services**:
   ```bash
   cd backend
   dart run bin/server.dart
   ```

2. **Test Web3 endpoints**:
   - `GET /api/v1/web3/status` - Check Web3 service status
   - `GET /api/v1/web3/contracts` - Get contract information
   - `POST /api/v1/web3/connect` - Test wallet connection

### 3. Mock Contract Testing

If you have Python installed, you can test the mock contracts directly:

```bash
cd smart-contracts
python mock_contracts.py
```

This will run a series of tests and show you the expected behavior.

## Expected Behavior

### Mock NFT Contract
- **Minting**: Creates NFT with mock token ID and transaction hash
- **Ownership**: Tracks NFT ownership correctly
- **Sales**: Allows putting NFTs for sale and buying them
- **Metadata**: Stores name, description, image, and attributes

### Mock Loyalty Contract
- **Registration**: Automatically registers users when they first interact
- **Minting**: Creates loyalty tokens with mock transaction
- **Balances**: Tracks user token balances
- **Transfers**: Allows token transfers between users

### Mock Web3 Service
- **Wallet Connection**: Generates mock wallet address from private key
- **Network Info**: Provides Sepolia testnet configuration
- **Transaction History**: Tracks all mock transactions
- **Gas Estimation**: Uses mock gas prices and limits

## Integration Points

### Frontend → Web3Provider
- Manages Web3 state (connection, wallet, NFTs, tokens)
- Integrates with both ApiService and Web3Service
- Handles wallet connection and disconnection

### Web3Provider → Web3Service
- Direct blockchain interactions
- Contract method calls
- Transaction signing and sending

### Web3Provider → ApiService
- Backend API calls for Web3 data
- User authentication and profile
- Social features integration

## Testing Scenarios

### 1. New User Flow
1. User registers in the app
2. User connects wallet (gets mock address)
3. User mints first NFT
4. User creates loyalty tokens
5. Verify all data is displayed correctly

### 2. Existing User Flow
1. User logs in
2. User connects wallet
3. User views existing NFTs and tokens
4. User performs transactions (mint, transfer, sell)
5. Verify transaction history updates

### 3. Error Handling
1. Test with invalid wallet address
2. Test with insufficient balance
3. Test with network errors
4. Verify error messages are displayed

### 4. UI Responsiveness
1. Test loading states
2. Test error states
3. Test empty states
4. Verify smooth transitions

## Debugging

### Common Issues

1. **Wallet Connection Fails**:
   - Check if Web3Provider is properly initialized
   - Verify wallet connection method is called
   - Check console for error messages

2. **NFTs Not Displaying**:
   - Verify Web3Provider state
   - Check if user NFTs are loaded
   - Verify NFT grid widget is properly configured

3. **Transactions Not Working**:
   - Check Web3Service configuration
   - Verify contract addresses are correct
   - Check gas settings

### Debug Tools

1. **Flutter Inspector**: Use to inspect widget tree and state
2. **Console Logs**: Check for error messages and debug info
3. **Provider State**: Use Provider.of to inspect state
4. **Network Tab**: Check API calls and responses

## Next Steps

After successful testing with mock contracts:

1. **Deploy Real Contracts**:
   - Use Hardhat to compile and deploy
   - Deploy to Sepolia testnet
   - Update contract addresses in config

2. **MetaMask Integration**:
   - Implement real wallet connection
   - Handle network switching
   - Add transaction confirmation dialogs

3. **IPFS Integration**:
   - Upload NFT metadata to IPFS
   - Store images on decentralized storage
   - Implement IPFS gateway fallbacks

4. **Production Deployment**:
   - Deploy to mainnet
   - Implement proper error handling
   - Add monitoring and analytics

## Support

If you encounter issues during testing:

1. Check the console for error messages
2. Verify all dependencies are installed
3. Ensure backend services are running
4. Check network connectivity
5. Review the mock contract implementation

## Mock Contract Implementation Details

The mock contracts are implemented in Python (`mock_contracts.py`) and provide:

- **Full ERC-721 functionality** for NFTs
- **Full ERC-20 functionality** for loyalty tokens
- **Transaction simulation** with mock hashes
- **State management** for testing scenarios
- **Error handling** for edge cases

This allows you to test the complete Web3 integration flow without blockchain deployment.
