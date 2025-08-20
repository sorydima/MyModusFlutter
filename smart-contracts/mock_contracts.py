#!/usr/bin/env python3
"""
Mock Smart Contracts for MyModus Web3 Testing
This script provides mock contract functionality for testing without actual deployment
"""

import json
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime

@dataclass
class NFTMetadata:
    name: str
    description: str
    image: str
    attributes: List[Dict[str, str]]
    token_id: int
    owner: str
    mint_date: str
    price: Optional[str] = None
    is_for_sale: bool = False

@dataclass
class LoyaltyToken:
    name: str
    symbol: str
    decimals: int
    total_supply: str
    user_balance: str
    user_address: str

@dataclass
class Transaction:
    hash: str
    from_address: str
    to_address: str
    value: str
    gas_used: int
    gas_price: str
    block_number: int
    timestamp: str
    status: str
    contract_address: Optional[str] = None
    method: Optional[str] = None

class MockMyModusNFT:
    """Mock implementation of MyModusNFT contract"""
    
    def __init__(self):
        self.name = "MyModus NFT Collection"
        self.symbol = "MMNFT"
        self.base_uri = "ipfs://"
        self.total_supply = 0
        self.max_supply = 10000
        self.mint_price = "100000000000000000"  # 0.1 ETH
        self.nfts: Dict[int, NFTMetadata] = {}
        self.owners: Dict[str, List[int]] = {}
        self.for_sale: Dict[int, str] = {}  # token_id -> price
        
    def mint(self, to_address: str, name: str, description: str, image: str, 
             attributes: List[Dict[str, str]]) -> Tuple[int, str]:
        """Mint a new NFT"""
        if self.total_supply >= self.max_supply:
            raise Exception("Max supply reached")
            
        token_id = self.total_supply + 1
        self.total_supply += 1
        
        # Create NFT metadata
        nft = NFTMetadata(
            name=name,
            description=description,
            image=image,
            attributes=attributes,
            token_id=token_id,
            owner=to_address,
            mint_date=datetime.now().isoformat(),
            price=None,
            is_for_sale=False
        )
        
        self.nfts[token_id] = nft
        
        # Update owner's NFT list
        if to_address not in self.owners:
            self.owners[to_address] = []
        self.owners[to_address].append(token_id)
        
        # Generate mock transaction hash
        tx_hash = f"0x{token_id:064x}"
        
        return token_id, tx_hash
        
    def put_for_sale(self, token_id: int, price: str, seller: str) -> str:
        """Put NFT for sale"""
        if token_id not in self.nfts:
            raise Exception("NFT does not exist")
            
        nft = self.nfts[token_id]
        if nft.owner != seller:
            raise Exception("Not the owner")
            
        nft.price = price
        nft.is_for_sale = True
        self.for_sale[token_id] = price
        
        # Generate mock transaction hash
        tx_hash = f"0x{token_id:064x}_sale"
        return tx_hash
        
    def remove_from_sale(self, token_id: int, seller: str) -> str:
        """Remove NFT from sale"""
        if token_id not in self.nfts:
            raise Exception("NFT does not exist")
            
        nft = self.nfts[token_id]
        if nft.owner != seller:
            raise Exception("Not the owner")
            
        nft.is_for_sale = False
        if token_id in self.for_sale:
            del self.for_sale[token_id]
            
        # Generate mock transaction hash
        tx_hash = f"0x{token_id:064x}_remove"
        return tx_hash
        
    def buy_nft(self, token_id: int, buyer: str, price: str) -> str:
        """Buy NFT from sale"""
        if token_id not in self.for_sale:
            raise Exception("NFT not for sale")
            
        if self.for_sale[token_id] != price:
            raise Exception("Price mismatch")
            
        nft = self.nfts[token_id]
        old_owner = nft.owner
        
        # Transfer ownership
        nft.owner = buyer
        nft.is_for_sale = False
        nft.price = None
        
        # Update owner lists
        if old_owner in self.owners:
            self.owners[old_owner].remove(token_id)
        if buyer not in self.owners:
            self.owners[buyer] = []
        self.owners[buyer].append(token_id)
        
        del self.for_sale[token_id]
        
        # Generate mock transaction hash
        tx_hash = f"0x{token_id:064x}_buy"
        return tx_hash
        
    def get_nft(self, token_id: int) -> Optional[NFTMetadata]:
        """Get NFT by token ID"""
        return self.nfts.get(token_id)
        
    def get_user_nfts(self, user_address: str) -> List[NFTMetadata]:
        """Get all NFTs owned by user"""
        if user_address not in self.owners:
            return []
        return [self.nfts[token_id] for token_id in self.owners[user_address]]
        
    def get_nfts_for_sale(self) -> List[NFTMetadata]:
        """Get all NFTs currently for sale"""
        return [self.nfts[token_id] for token_id in self.for_sale.keys()]
        
    def get_contract_info(self) -> Dict:
        """Get contract information"""
        return {
            "name": self.name,
            "symbol": self.symbol,
            "totalSupply": self.total_supply,
            "maxSupply": self.max_supply,
            "mintPrice": self.mint_price,
            "baseURI": self.base_uri
        }

class MockMyModusLoyalty:
    """Mock implementation of MyModusLoyalty contract"""
    
    def __init__(self):
        self.name = "MyModus Loyalty Token"
        self.symbol = "MMLT"
        self.decimals = 18
        self.total_supply = "1000000000000000000000000"  # 1,000,000 tokens
        self.mint_price = "100000000000000000"  # 0.1 ETH
        self.balances: Dict[str, str] = {}
        self.users: Dict[str, bool] = {}
        self.minters: List[str] = []
        self.burners: List[str] = []
        self.paused = False
        
    def register_user(self, user_address: str) -> str:
        """Register a new user"""
        if user_address in self.users:
            raise Exception("User already registered")
            
        self.users[user_address] = True
        self.balances[user_address] = "0"
        
        # Generate mock transaction hash
        tx_hash = f"0x{hash(user_address) % 1000000:064x}"
        return tx_hash
        
    def mint_tokens(self, to_address: str, amount: str, 
                   from_address: str = None) -> str:
        """Mint loyalty tokens"""
        if self.paused:
            raise Exception("Contract is paused")
            
        if from_address and from_address not in self.minters:
            raise Exception("Not authorized to mint")
            
        if to_address not in self.users:
            raise Exception("User not registered")
            
        current_balance = self.balances.get(to_address, "0")
        new_balance = str(int(current_balance) + int(amount))
        self.balances[to_address] = new_balance
        
        # Generate mock transaction hash
        tx_hash = f"0x{hash(f'{to_address}_{amount}') % 1000000:064x}"
        return tx_hash
        
    def burn_tokens(self, from_address: str, amount: str, 
                   burner_address: str = None) -> str:
        """Burn loyalty tokens"""
        if self.paused:
            raise Exception("Contract is paused")
            
        if burner_address and burner_address not in self.burners:
            raise Exception("Not authorized to burn")
            
        if from_address not in self.users:
            raise Exception("User not registered")
            
        current_balance = self.balances.get(from_address, "0")
        if int(current_balance) < int(amount):
            raise Exception("Insufficient balance")
            
        new_balance = str(int(current_balance) - int(amount))
        self.balances[from_address] = new_balance
        
        # Generate mock transaction hash
        tx_hash = f"0x{hash(f'{from_address}_{amount}_burn') % 1000000:064x}"
        return tx_hash
        
    def transfer_tokens(self, from_address: str, to_address: str, 
                       amount: str) -> str:
        """Transfer tokens between users"""
        if self.paused:
            raise Exception("Contract is paused")
            
        if from_address not in self.users or to_address not in self.users:
            raise Exception("User not registered")
            
        current_balance = self.balances.get(from_address, "0")
        if int(current_balance) < int(amount):
            raise Exception("Insufficient balance")
            
        # Update balances
        new_from_balance = str(int(current_balance) - int(amount))
        self.balances[from_address] = new_from_balance
        
        current_to_balance = self.balances.get(to_address, "0")
        new_to_balance = str(int(current_to_balance) + int(amount))
        self.balances[to_address] = new_to_balance
        
        # Generate mock transaction hash
        tx_hash = f"0x{hash(f'{from_address}_{to_address}_{amount}') % 1000000:064x}"
        return tx_hash
        
    def get_balance(self, user_address: str) -> str:
        """Get user's token balance"""
        return self.balances.get(user_address, "0")
        
    def get_user_info(self, user_address: str) -> Optional[Dict]:
        """Get user information"""
        if user_address not in self.users:
            return None
            
        return {
            "address": user_address,
            "registered": self.users[user_address],
            "balance": self.balances.get(user_address, "0"),
            "isMinter": user_address in self.minters,
            "isBurner": user_address in self.burners
        }
        
    def get_contract_info(self) -> Dict:
        """Get contract information"""
        return {
            "name": self.name,
            "symbol": self.symbol,
            "decimals": self.decimals,
            "totalSupply": self.total_supply,
            "mintPrice": self.mint_price,
            "paused": self.paused
        }

class MockWeb3Service:
    """Mock Web3 service for testing"""
    
    def __init__(self):
        self.nft_contract = MockMyModusNFT()
        self.loyalty_contract = MockMyModusLoyalty()
        self.transactions: List[Transaction] = []
        self.current_block = 1000000
        self.gas_price = "20000000000"  # 20 Gwei
        
    def connect_wallet(self, private_key: str) -> Dict:
        """Mock wallet connection"""
        # Generate mock address from private key
        address = f"0x{hash(private_key) % 1000000000000000000000000000000000000000:040x}"
        
        return {
            "address": address,
            "chainId": 11155111,  # Sepolia
            "network": "sepolia",
            "connected": True
        }
        
    def get_balance(self, address: str) -> str:
        """Get ETH balance"""
        # Mock balance
        balance = hash(address) % 1000000000000000000000  # 0-1 ETH
        return str(balance)
        
    def mint_nft(self, to_address: str, name: str, description: str, 
                 image: str, attributes: List[Dict[str, str]]) -> Dict:
        """Mint NFT"""
        try:
            token_id, tx_hash = self.nft_contract.mint(
                to_address, name, description, image, attributes
            )
            
            # Create transaction record
            tx = Transaction(
                hash=tx_hash,
                from_address="0x0000000000000000000000000000000000000000",
                to_address=to_address,
                value="0",
                gas_used=150000,
                gas_price=self.gas_price,
                block_number=self.current_block,
                timestamp=datetime.now().isoformat(),
                status="success",
                contract_address="0x1234567890123456789012345678901234567890",
                method="mint"
            )
            self.transactions.append(tx)
            self.current_block += 1
            
            return {
                "success": True,
                "tokenId": token_id,
                "transactionHash": tx_hash,
                "contractAddress": "0x1234567890123456789012345678901234567890"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
            
    def create_loyalty_tokens(self, to_address: str, amount: str) -> Dict:
        """Create loyalty tokens"""
        try:
            # Register user if not exists
            if to_address not in self.loyalty_contract.users:
                self.loyalty_contract.register_user(to_address)
                
            # Mint tokens
            tx_hash = self.loyalty_contract.mint_tokens(to_address, amount)
            
            # Create transaction record
            tx = Transaction(
                hash=tx_hash,
                from_address="0x0000000000000000000000000000000000000000",
                to_address=to_address,
                value=amount,
                gas_used=100000,
                gas_price=self.gas_price,
                block_number=self.current_block,
                timestamp=datetime.now().isoformat(),
                status="success",
                contract_address="0x0987654321098765432109876543210987654321",
                method="mint"
            )
            self.transactions.append(tx)
            self.current_block += 1
            
            return {
                "success": True,
                "transactionHash": tx_hash,
                "contractAddress": "0x0987654321098765432109876543210987654321"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
            
    def get_user_nfts(self, user_address: str) -> List[Dict]:
        """Get user's NFTs"""
        nfts = self.nft_contract.get_user_nfts(user_address)
        return [asdict(nft) for nft in nfts]
        
    def get_nfts_for_sale(self) -> List[Dict]:
        """Get NFTs for sale"""
        nfts = self.nft_contract.get_nfts_for_sale()
        return [asdict(nft) for nft in nfts]
        
    def get_loyalty_balance(self, user_address: str) -> str:
        """Get user's loyalty token balance"""
        return self.loyalty_contract.get_balance(user_address)
        
    def get_transaction_history(self, address: str, limit: int = 50) -> List[Dict]:
        """Get transaction history for address"""
        user_txs = [
            tx for tx in self.transactions 
            if tx.from_address == address or tx.to_address == address
        ]
        
        # Sort by timestamp (newest first)
        user_txs.sort(key=lambda x: x.timestamp, reverse=True)
        
        return [asdict(tx) for tx in user_txs[:limit]]
        
    def get_contract_addresses(self) -> Dict:
        """Get deployed contract addresses"""
        return {
            "MyModusNFT": "0x1234567890123456789012345678901234567890",
            "MyModusLoyalty": "0x0987654321098765432109876543210987654321"
        }
        
    def get_network_info(self) -> Dict:
        """Get current network information"""
        return {
            "chainId": 11155111,
            "name": "Sepolia Testnet",
            "rpcUrl": "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID",
            "explorerUrl": "https://sepolia.etherscan.io",
            "currencySymbol": "ETH",
            "isTestnet": True
        }

def main():
    """Test the mock contracts"""
    print("🧪 Testing Mock MyModus Smart Contracts")
    print("=" * 50)
    
    # Initialize mock service
    web3_service = MockWeb3Service()
    
    # Test wallet connection
    print("\n1. Testing wallet connection...")
    wallet_info = web3_service.connect_wallet("test_private_key")
    print(f"Connected wallet: {wallet_info}")
    
    # Test NFT minting
    print("\n2. Testing NFT minting...")
    nft_result = web3_service.mint_nft(
        wallet_info["address"],
        "Test NFT",
        "This is a test NFT",
        "https://via.placeholder.com/400x400",
        [{"trait_type": "Type", "value": "Test"}]
    )
    print(f"NFT mint result: {nft_result}")
    
    # Test loyalty token creation
    print("\n3. Testing loyalty token creation...")
    loyalty_result = web3_service.create_loyalty_tokens(
        wallet_info["address"],
        "1000000000000000000000"  # 1000 tokens
    )
    print(f"Loyalty token result: {loyalty_result}")
    
    # Test getting user data
    print("\n4. Testing user data retrieval...")
    user_nfts = web3_service.get_user_nfts(wallet_info["address"])
    print(f"User NFTs: {len(user_nfts)} found")
    
    loyalty_balance = web3_service.get_loyalty_balance(wallet_info["address"])
    print(f"Loyalty balance: {loyalty_balance}")
    
    # Test transaction history
    print("\n5. Testing transaction history...")
    tx_history = web3_service.get_transaction_history(wallet_info["address"])
    print(f"Transaction history: {len(tx_history)} transactions")
    
    # Test contract info
    print("\n6. Testing contract information...")
    nft_info = web3_service.nft_contract.get_contract_info()
    loyalty_info = web3_service.loyalty_contract.get_contract_info()
    
    print(f"NFT Contract: {nft_info['name']} ({nft_info['symbol']})")
    print(f"Loyalty Contract: {loyalty_info['name']} ({loyalty_info['symbol']})")
    
    print("\n✅ All tests completed successfully!")
    print("\n📋 Mock Contract Addresses:")
    addresses = web3_service.get_contract_addresses()
    for name, address in addresses.items():
        print(f"  {name}: {address}")
        
    print("\n🔗 To use in frontend, update web3_config.dart with these addresses")

if __name__ == "__main__":
    main()
