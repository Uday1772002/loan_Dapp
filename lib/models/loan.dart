class Loan {
  final BigInt id;
  final String borrower;
  final String lender;
  final BigInt amount;
  final BigInt interestRate;
  final BigInt duration;
  final BigInt startTime;
  final BigInt repaymentAmount;
  final bool isActive;
  final bool isRepaid;
  final bool isSanctioned;

  Loan({
    required this.id,
    required this.borrower,
    required this.lender,
    required this.amount,
    required this.interestRate,
    required this.duration,
    required this.startTime,
    required this.repaymentAmount,
    required this.isActive,
    required this.isRepaid,
    required this.isSanctioned,
  });

  factory Loan.fromList(List<dynamic> data) {
    return Loan(
      id: data[0] as BigInt,
      borrower: data[1] as String,
      lender: data[2] as String,
      amount: data[3] as BigInt,
      interestRate: data[4] as BigInt,
      duration: data[5] as BigInt,
      startTime: data[6] as BigInt,
      repaymentAmount: data[7] as BigInt,
      isActive: data[8] as bool,
      isRepaid: data[9] as bool,
      isSanctioned: data[10] as bool,
    );
  }

  double get amountInEth => amount.toDouble() / 1e18;
  double get repaymentInEth => repaymentAmount.toDouble() / 1e18;

  String get statusText {
    if (isRepaid) return 'Repaid';
    if (isActive) return 'Active';
    if (isSanctioned) return 'Sanctioned';
    return 'Pending';
  }

  String get shortBorrower =>
      '${borrower.substring(0, 6)}...${borrower.substring(borrower.length - 4)}';
  String get shortLender => lender ==
          '0x0000000000000000000000000000000000000000'
      ? 'Not assigned'
      : '${lender.substring(0, 6)}...${lender.substring(lender.length - 4)}';
}
