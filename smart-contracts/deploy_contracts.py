#!/usr/bin/env python3
"""
Smart Contract Deployment Script for MyModus
Deploys MyModusNFT and MyModusLoyalty contracts to testnet
"""

import json
import os
import sys
from web3 import Web3
from eth_account import Account
import time

class ContractDeployer:
    def __init__(self, config_file="contracts_config.json"):
        self.config = self.load_config(config_file)
        self.w3 = None
        self.account = None
        self.contracts = {}
        
    def load_config(self, config_file):
        """Load configuration from JSON file"""
        try:
            with open(config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: {config_file} not found")
            sys.exit(1)
            
    def connect_to_network(self, network_name):
        """Connect to specified network"""
        if network_name not in self.config['networks']:
            print(f"Error: Network {network_name} not found in config")
            sys.exit(1)
            
        network = self.config['networks'][network_name]
        url = network['url']
        
        # Replace placeholder with actual Infura project ID
        if 'YOUR_INFURA_PROJECT_ID' in url:
            project_id = input("Enter your Infura Project ID: ").strip()
            url = url.replace('YOUR_INFURA_PROJECT_ID', project_id)
            
        try:
            self.w3 = Web3(Web3.HTTPProvider(url))
            if not self.w3.is_connected():
                print(f"Error: Could not connect to {network_name}")
                sys.exit(1)
                
            print(f"Connected to {network_name} network")
            print(f"Chain ID: {network['chainId']}")
            print(f"Current block: {self.w3.eth.block_number}")
            
        except Exception as e:
            print(f"Error connecting to network: {e}")
            sys.exit(1)
            
    def setup_account(self):
        """Setup account for deployment"""
        private_key = input("Enter your private key (without 0x): ").strip()
        if not private_key.startswith('0x'):
            private_key = '0x' + private_key
            
        try:
            self.account = Account.from_key(private_key)
            balance = self.w3.eth.get_balance(self.account.address)
            balance_eth = self.w3.from_wei(balance, 'ether')
            
            print(f"Account: {self.account.address}")
            print(f"Balance: {balance_eth} ETH")
            
            if balance_eth < 0.01:
                print("Warning: Low balance for deployment")
                
        except Exception as e:
            print(f"Error setting up account: {e}")
            sys.exit(1)
            
    def load_contract_abi(self, contract_name):
        """Load contract ABI from file"""
        try:
            abi_path = f"abi/{contract_name}.json"
            with open(abi_path, 'r') as f:
                abi_data = json.load(f)
                return abi_data['abi']
        except FileNotFoundError:
            print(f"Error: ABI file for {contract_name} not found")
            return None
            
    def deploy_contract(self, contract_name, contract_class, *args):
        """Deploy a contract"""
        print(f"\nDeploying {contract_name}...")
        
        # Load contract ABI
        abi = self.load_contract_abi(contract_name)
        if not abi:
            return None
            
        # Create contract instance
        contract = self.w3.eth.contract(abi=abi, bytecode=contract_class.bytecode)
        
        # Build transaction
        gas_estimate = contract.constructor(*args).estimate_gas({
            'from': self.account.address,
            'nonce': self.w3.eth.get_transaction_count(self.account.address)
        })
        
        gas_limit = int(gas_estimate * 1.2)  # Add 20% buffer
        
        transaction = contract.constructor(*args).build_transaction({
            'from': self.account.address,
            'nonce': self.w3.eth.get_transaction_count(self.account.address),
            'gas': gas_limit,
            'gasPrice': self.w3.eth.gas_price
        })
        
        # Sign and send transaction
        signed_txn = self.w3.eth.account.sign_transaction(transaction, self.account.key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        
        print(f"Transaction sent: {tx_hash.hex()}")
        print("Waiting for confirmation...")
        
        # Wait for confirmation
        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        
        if tx_receipt.status == 1:
            contract_address = tx_receipt.contractAddress
            print(f"✅ {contract_name} deployed successfully!")
            print(f"Address: {contract_address}")
            print(f"Gas used: {tx_receipt.gasUsed}")
            return contract_address
        else:
            print(f"❌ {contract_name} deployment failed!")
            return None
            
    def update_config(self, network_name, contract_name, address):
        """Update configuration with deployed contract address"""
        self.config['networks'][network_name]['contracts'][contract_name]['address'] = address
        
        with open('contracts_config.json', 'w') as f:
            json.dump(self.config, f, indent=2)
            
        print(f"Updated config with {contract_name} address")
        
    def deploy_all_contracts(self, network_name):
        """Deploy all contracts to specified network"""
        print(f"\n🚀 Starting deployment to {network_name} network...")
        
        # Connect to network
        self.connect_to_network(network_name)
        
        # Setup account
        self.setup_account()
        
        # Deploy MyModusNFT
        nft_settings = self.config['contractSettings']['MyModusNFT']
        nft_address = self.deploy_contract(
            'MyModusNFT',
            MyModusNFT,  # This would need to be imported from compiled contracts
            nft_settings['name'],
            nft_settings['symbol'],
            nft_settings['baseURI']
        )
        
        if nft_address:
            self.update_config(network_name, 'MyModusNFT', nft_address)
            self.contracts['MyModusNFT'] = nft_address
            
        # Deploy MyModusLoyalty
        loyalty_settings = self.config['contractSettings']['MyModusLoyalty']
        loyalty_address = self.deploy_contract(
            'MyModusLoyalty',
            MyModusLoyalty,  # This would need to be imported from compiled contracts
            loyalty_settings['name'],
            loyalty_settings['symbol'],
            loyalty_settings['decimals'],
            loyalty_settings['initialSupply'],
            loyalty_settings['mintPrice']
        )
        
        if loyalty_address:
            self.update_config(network_name, 'MyModusLoyalty', loyalty_address)
            self.contracts['MyModusLoyalty'] = loyalty_address
            
        # Save deployment results
        deployment_results = {
            'network': network_name,
            'timestamp': int(time.time()),
            'contracts': self.contracts
        }
        
        with open('deployment_results.json', 'w') as f:
            json.dump(deployment_results, f, indent=2)
            
        print(f"\n📋 Deployment Summary:")
        print(f"Network: {network_name}")
        for name, address in self.contracts.items():
            print(f"{name}: {address}")
            
        print(f"\nResults saved to deployment_results.json")
        print(f"Configuration updated in contracts_config.json")

def main():
    """Main deployment function"""
    print("🚀 MyModus Smart Contract Deployer")
    print("=" * 40)
    
    # Available networks
    networks = ['hardhat', 'ganache', 'sepolia', 'mumbai']
    print("\nAvailable networks:")
    for i, network in enumerate(networks, 1):
        print(f"{i}. {network}")
        
    # Get network choice
    while True:
        try:
            choice = int(input("\nSelect network (1-4): ")) - 1
            if 0 <= choice < len(networks):
                selected_network = networks[choice]
                break
            else:
                print("Invalid choice. Please select 1-4.")
        except ValueError:
            print("Please enter a number.")
            
    print(f"\nSelected network: {selected_network}")
    
    # Initialize deployer
    deployer = ContractDeployer()
    
    # Deploy contracts
    deployer.deploy_all_contracts(selected_network)

if __name__ == "__main__":
    main()
