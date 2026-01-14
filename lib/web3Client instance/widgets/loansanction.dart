import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../client instance.dart';

class LoanSanctionForm extends StatefulWidget {
  final String lenderAddress;

  const LoanSanctionForm({super.key, required this.lenderAddress});

  @override
  State<LoanSanctionForm> createState() => _LoanSanctionFormState();
}

class _LoanSanctionFormState extends State<LoanSanctionForm> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerAddressController = TextEditingController();
  final _interestRateController = TextEditingController();

  Future<void> _sanctionLoan() async {
    final credentials = EthPrivateKey.fromHex('<your_private_key>');
    final function = contract.function('sanctionLoan');
    final borrowerAddress =
        EthereumAddress.fromHex(_borrowerAddressController.text);
    final interestRate = int.parse(_interestRateController.text);
    final result = await web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [borrowerAddress, BigInt.from(interestRate)],
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
            decoration: InputDecoration(
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
            child: Text('Sanction Loan'),
          ),
        ],
      ),
    );
  }
}
