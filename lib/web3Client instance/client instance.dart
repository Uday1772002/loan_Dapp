

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

final web3 = Web3Client('http://localhost:7545', HttpClient() as Client);

const contractAbi = [
  // copy and paste the ABI code of your smart contract here
];

const contractAddress = '<your_contract_address>';
final contract = DeployedContract(ContractAbi.fromJson(contractAbi as String, 'LoanContract'), EthereumAddress.fromHex(contractAddress));

class LoanRequestForm extends StatefulWidget {
  final String borrowerAddress;

  const LoanRequestForm({super.key, required this.borrowerAddress});

  @override
  _LoanRequestFormState createState() => _LoanRequestFormState();
}

class _LoanRequestFormState extends State<LoanRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _deadlineController = TextEditingController();

  Future<void> _requestLoan() async {
    final credentials = await EtherWallet.fromPrivateKey('<your_private_key>');
    final function = contract.function('requestLoan');
    final deadline = int.parse(_deadlineController.text);
    final result = await web3.sendTransaction(
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [BigInt.from(deadline)],
      ) as Credentials,
      credentials,
      chainId: 1337, // replace with your chain ID
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _deadlineController,
            decoration: const InputDecoration(
              labelText: 'Deadline (in seconds)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a deadline';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _requestLoan();
              }
            },
            child: const Text('Request Loan'),
          ),
        ],
      ),
    );
  }
}

class EtherWallet {
  static fromPrivateKey(String s) {}
}

class LoanSanctionForm extends StatefulWidget {
  final String lenderAddress;

   LoanSanctionForm({required this.lenderAddress});

  @override
  _LoanSanctionFormState createState() => _LoanSanctionFormState();
}

class _LoanSanctionFormState extends State<LoanSanctionForm> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerAddressController = TextEditingController();
  final _interestRateController = TextEditingController();

  Future<void> _sanctionLoan() async {
    final credentials = await EtherWallet.fromPrivateKey('<your_private_key>');
    final function = contract.function('sanctionLoan');
    final borrowerAddress = EthereumAddress.fromHex(_borrowerAddressController.text);
    final interestRate = int.parse(_interestRateController.text);
    final result = await web3.sendTransaction(
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [borrowerAddress, BigInt.from(interestRate)],
      ) as Credentials,
      credentials,
      chainId: 1337, // replace with your chain ID
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _borrowerAddressController,
            decoration: const InputDecoration(
              labelText: 'Borrower Address',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the borrower address';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _interestRateController,
            decoration: const InputDecoration(
              labelText: 'Interest Rate',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the interest rate';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _sanctionLoan();
              }
            },
            child: const Text('Sanction Loan'),
          ),
        ],
      ),
    );
  }
}

class LoanRepayForm extends StatefulWidget {
  final String borrowerAddress;
  final BigInt amountToRepay;

  LoanRepayForm({required this.borrowerAddress, required this.amountToRepay});

  @override
  _LoanRepayFormState createState() => _LoanRepayFormState();
}

class _LoanRepayFormState extends State<LoanRepayForm> {
  Future<void> _repayLoan() async {
    final credentials = await EtherWallet.fromPrivateKey('<your_private_key>');
    final function = contract.function('repayLoan');
    final result = await web3.sendTransaction(
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [],
        // ignore: deprecated_member_use
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, widget.amountToRepay.toInt()),
      ) as Credentials,
      credentials,
      chainId: 1337, // replace with your chain ID
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount to Repay: ${widget.amountToRepay} ETH'),
        ElevatedButton(
          onPressed: () {
            _repayLoan();
          },
          child: const Text('Repay Loan'),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  final borrowerAddress = '<your_borrower_address>';
  final lenderAddress = '<your_lender_address>';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Contract',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Loan Contract'),
        ),
        body: FutureBuilder<EtherAmount>(
          future: web3.getBalance(EthereumAddress.fromHex(borrowerAddress)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final balance = snapshot.data!;
              
              if (balance.getInEther > BigInt.zero) {
                return LoanRepayForm(
                  borrowerAddress: borrowerAddress,
                  amountToRepay: balance.getInEther,
                );
              } else {
                return LoanRequestForm(
                  borrowerAddress: borrowerAddress,
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}