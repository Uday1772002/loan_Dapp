import 'package:flutter/material.dart';
import 'package:loan_dapp/web3Client%20instance/client%20instance.dart';
import 'package:web3dart/web3dart.dart';

class MyApp extends StatelessWidget {
  final borrowerAddress = '<your_borrower_address>';
  final lenderAddress = '<your_lender_address>';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Contract',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Loan Contract'),
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