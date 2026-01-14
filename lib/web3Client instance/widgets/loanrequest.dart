import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../client instance.dart';

class LoanRequestForm extends StatefulWidget {
  final String borrowerAddress;

  const LoanRequestForm({super.key, required this.borrowerAddress});

  @override
  State<LoanRequestForm> createState() => _LoanRequestFormState();
}

class _LoanRequestFormState extends State<LoanRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _deadlineController = TextEditingController();

  Future<void> _requestLoan() async {
    final credentials = EthPrivateKey.fromHex('<your_private_key>');
    final function = contract.function('requestLoan');
    final deadline = int.parse(_deadlineController.text);
    final result = await web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [BigInt.from(deadline)],
      ),
      chainId: 1337, // replace with your chain ID
    );
    debugPrint(result);
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
