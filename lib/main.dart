import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/connect_wallet_screen.dart';
import 'screens/home_screen.dart';
import 'services/web3_service.dart';

void main() {
  runApp(const LoanDApp());
}

class LoanDApp extends StatefulWidget {
  const LoanDApp({super.key});

  @override
  State<LoanDApp> createState() => _LoanDAppState();
}

class _LoanDAppState extends State<LoanDApp> {
  bool _isConnected = false;

  Future<void> _connectWallet(String privateKey, String contractAddress) async {
    try {
      final web3 = Web3Service();
      await web3.initialize(
        privateKey: privateKey.replaceAll('0x', ''),
        contractAddress: contractAddress,
      );

      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan DApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: _isConnected
          ? const HomeScreen()
          : ConnectWalletScreen(onConnect: _connectWallet),
    );
  }
}
