import 'package:http/http.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

// Re-export types so they can be used from widgets
export 'package:wallet/wallet.dart'
    show EthereumAddress, EtherAmount, EtherUnit;
export 'package:web3dart/web3dart.dart' show EthPrivateKey;

// Export widget classes from their respective files
export 'widgets/loanrequest.dart';
export 'widgets/loanrepay.dart';
export 'widgets/loansanction.dart';

/// Web3 client connected to local Ganache instance
final web3 = Web3Client('http://localhost:7545', Client());

/// Contract ABI - paste your smart contract ABI here
const contractAbi = [
  // copy and paste the ABI code of your smart contract here
];

/// Deployed contract address - replace with your contract address
// TODO: Replace with your actual deployed contract address
const contractAddress = '0x0000000000000000000000000000000000000000';

/// Deployed contract instance
final contract = DeployedContract(
  ContractAbi.fromJson(contractAbi as String, 'LoanContract'),
  EthereumAddress.fromHex(contractAddress),
);
