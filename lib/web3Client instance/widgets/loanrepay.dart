import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../client instance.dart';
class LoanRepayForm extends StatefulWidget {
  final String borrowerAddress;
  final BigInt amountToRepay;

  LoanRepayForm({required this.borrowerAddress, required this.amountToRepay});

  @override
  _LoanRepayFormState createState() => _LoanRepayFormState();
}

class _LoanRepayFormState extends State<LoanRepayForm> {
  Future<void> _repayLoan() async {
    final credentials = await web3.credentialsFromPrivateKey('<your_private_key>');
    final function = contract.function('repayLoan');
    final result = await web3.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [],
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, widget.amountToRepay.toInt()),
      ),
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