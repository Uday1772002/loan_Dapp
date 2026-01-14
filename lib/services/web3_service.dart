import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class Web3Service {
  static final Web3Service _instance = Web3Service._internal();
  factory Web3Service() => _instance;
  Web3Service._internal();

  late Web3Client _client;
  late DeployedContract _contract;
  late EthPrivateKey _credentials;
  late EthereumAddress _userAddress;

  bool _isInitialized = false;

  // Ganache default RPC URL
  final String _rpcUrl = 'http://localhost:7545';

  // Contract address - UPDATE THIS after deploying contract
  String _contractAddress = '';

  Web3Client get client => _client;
  EthereumAddress get userAddress => _userAddress;
  bool get isInitialized => _isInitialized;
  String get contractAddress => _contractAddress;

  Future<void> initialize({
    required String privateKey,
    required String contractAddress,
  }) async {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddress = contractAddress;

    // Load credentials from private key
    _credentials = EthPrivateKey.fromHex(privateKey);
    _userAddress = _credentials.address;

    // Load contract ABI
    final abiString = await rootBundle.loadString('assets/abi.json');
    final abiJson = jsonDecode(abiString);

    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abiJson), 'LoanContract'),
      EthereumAddress.fromHex(contractAddress),
    );

    _isInitialized = true;
  }

  Future<EtherAmount> getBalance([EthereumAddress? address]) async {
    return await _client.getBalance(address ?? _userAddress);
  }

  Future<String> requestLoan(BigInt amountWei, BigInt durationSeconds) async {
    final function = _contract.function('requestLoan');

    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [amountWei, durationSeconds],
      ),
      chainId: 1337,
    );

    return result;
  }

  Future<String> sanctionLoan(
      BigInt loanId, BigInt interestRate, BigInt amountWei) async {
    final function = _contract.function('sanctionLoan');

    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [loanId, interestRate],
        value: EtherAmount.inWei(amountWei),
      ),
      chainId: 1337,
    );

    return result;
  }

  Future<String> repayLoan(BigInt loanId, BigInt repaymentAmount) async {
    final function = _contract.function('repayLoan');

    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [loanId],
        value: EtherAmount.inWei(repaymentAmount),
      ),
      chainId: 1337,
    );

    return result;
  }

  Future<String> cancelLoan(BigInt loanId) async {
    final function = _contract.function('cancelLoan');

    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [loanId],
      ),
      chainId: 1337,
    );

    return result;
  }

  Future<List<dynamic>> getLoan(BigInt loanId) async {
    final function = _contract.function('getLoan');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [loanId],
    );
    return result;
  }

  Future<BigInt> getLoanCounter() async {
    final function = _contract.function('loanCounter');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );
    return result[0] as BigInt;
  }

  Future<List<BigInt>> getBorrowerLoans(EthereumAddress borrower) async {
    final function = _contract.function('getBorrowerLoans');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [borrower],
    );
    return (result[0] as List).cast<BigInt>();
  }

  Future<List<BigInt>> getLenderLoans(EthereumAddress lender) async {
    final function = _contract.function('getLenderLoans');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [lender],
    );
    return (result[0] as List).cast<BigInt>();
  }

  void dispose() {
    _client.dispose();
  }
}
