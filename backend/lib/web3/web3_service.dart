import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

class Web3Service {
  late Web3Client client;
  late String rpcUrl;

  Web3Service() {
    dotenv.load();
    rpcUrl = dotenv.env['ETH_RPC_URL'] ?? '';
    if (rpcUrl.isEmpty) {
      throw Exception('ETH_RPC_URL not set');
    }
    client = Web3Client(rpcUrl, http.Client());
  }

  Future<EthereumAddress> addressFromPrivateKey(String privateKey) async {
    final creds = EthPrivateKey.fromHex(privateKey);
    final address = await creds.extractAddress();
    return address;
  }

  Future<String> sendRawTransaction(String privateKey, String toHex, BigInt valueWei) async {
    final creds = EthPrivateKey.fromHex(privateKey);
    final tx = Transaction(
      to: EthereumAddress.fromHex(toHex),
      value: EtherAmount.inWei(valueWei),
      gasPrice: await client.getGasPrice(),
    );
    final signed = await client.sendTransaction(creds, tx, chainId: null, fetchChainIdFromNetworkId: true);
    return signed;
  }

  Future<EtherAmount> getBalance(String addressHex) async {
    final address = EthereumAddress.fromHex(addressHex);
    return client.getBalance(address);
  }
}
