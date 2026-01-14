import 'package:flutter/material.dart';
import '../services/web3_service.dart';
import '../theme/app_theme.dart';
import '../models/loan.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Web3Service _web3 = Web3Service();
  List<Loan> _borrowedLoans = [];
  List<Loan> _lentLoans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      // Load borrowed loans
      final borrowedIds = await _web3.getBorrowerLoans(_web3.userAddress);
      final borrowed = <Loan>[];
      for (final id in borrowedIds) {
        try {
          final loanData = await _web3.getLoan(id);
          if (loanData.isNotEmpty) {
            borrowed.add(Loan.fromList(loanData[0] as List));
          }
        } catch (e) {
          debugPrint('Error loading loan $id: $e');
        }
      }

      // Load lent loans
      final lentIds = await _web3.getLenderLoans(_web3.userAddress);
      final lent = <Loan>[];
      for (final id in lentIds) {
        try {
          final loanData = await _web3.getLoan(id);
          if (loanData.isNotEmpty) {
            lent.add(Loan.fromList(loanData[0] as List));
          }
        } catch (e) {
          debugPrint('Error loading loan $id: $e');
        }
      }

      setState(() {
        _borrowedLoans = borrowed;
        _lentLoans = lent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading loans: $e')),
        );
      }
    }
  }

  Future<void> _repayLoan(Loan loan) async {
    try {
      _showLoadingDialog();

      final txHash = await _web3.repayLoan(loan.id, loan.repaymentAmount);

      if (mounted) Navigator.pop(context);
      _showSuccessDialog('Loan Repaid!', txHash);
      _loadLoans();
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Processing...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String txHash) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: AppTheme.successColor, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'TX: ${txHash.substring(0, 20)}...',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRepayDialog(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Repay Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Principal',
                      '${loan.amountInEth.toStringAsFixed(4)} ETH'),
                  _buildDetailRow('Interest', '${loan.interestRate}%'),
                  const Divider(),
                  _buildDetailRow(
                    'Total Repayment',
                    '${loan.repaymentInEth.toStringAsFixed(4)} ETH',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _repayLoan(loan);
            },
            child: const Text('Repay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.arrow_downward),
              text: 'Borrowed (${_borrowedLoans.length})',
            ),
            Tab(
              icon: const Icon(Icons.arrow_upward),
              text: 'Lent (${_lentLoans.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLoans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLoansList(_borrowedLoans, isBorrowed: true),
                _buildLoansList(_lentLoans, isBorrowed: false),
              ],
            ),
    );
  }

  Widget _buildLoansList(List<Loan> loans, {required bool isBorrowed}) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBorrowed ? Icons.account_balance_wallet : Icons.savings,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isBorrowed ? 'No Borrowed Loans' : 'No Lent Loans',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBorrowed
                  ? 'You haven\'t borrowed any loans yet'
                  : 'You haven\'t funded any loans yet',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          return _buildLoanCard(loans[index], isBorrowed: isBorrowed);
        },
      ),
    );
  }

  Widget _buildLoanCard(Loan loan, {required bool isBorrowed}) {
    Color statusColor;
    String statusText = loan.statusText;

    switch (statusText) {
      case 'Repaid':
        statusColor = AppTheme.successColor;
        break;
      case 'Active':
        statusColor = AppTheme.primaryColor;
        break;
      default:
        statusColor = AppTheme.warningColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Loan #${loan.id}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Principal',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        '${loan.amountInEth.toStringAsFixed(4)} ETH',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loan.isSanctioned)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interest',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        Text(
                          '${loan.interestRate}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (loan.isSanctioned && !loan.isRepaid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Repayment Amount'),
                    Text(
                      '${loan.repaymentInEth.toStringAsFixed(4)} ETH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isBorrowed && loan.isActive && !loan.isRepaid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRepayDialog(loan),
                  icon: const Icon(Icons.payment),
                  label: const Text('Repay Loan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  isBorrowed
                      ? 'Lender: ${loan.shortLender}'
                      : 'Borrower: ${loan.shortBorrower}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
