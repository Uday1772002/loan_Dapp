// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanContract {
    
    struct Loan {
        uint256 id;
        address borrower;
        address lender;
        uint256 amount;
        uint256 interestRate; // in percentage (e.g., 5 = 5%)
        uint256 duration; // in seconds
        uint256 startTime;
        uint256 repaymentAmount;
        bool isActive;
        bool isRepaid;
        bool isSanctioned;
    }
    
    uint256 public loanCounter;
    mapping(uint256 => Loan) public loans;
    mapping(address => uint256[]) public borrowerLoans;
    mapping(address => uint256[]) public lenderLoans;
    
    event LoanRequested(uint256 indexed loanId, address indexed borrower, uint256 amount, uint256 duration);
    event LoanSanctioned(uint256 indexed loanId, address indexed lender, uint256 interestRate);
    event LoanRepaid(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event LoanCancelled(uint256 indexed loanId);
    
    modifier onlyBorrower(uint256 _loanId) {
        require(loans[_loanId].borrower == msg.sender, "Not the borrower");
        _;
    }
    
    modifier onlyLender(uint256 _loanId) {
        require(loans[_loanId].lender == msg.sender, "Not the lender");
        _;
    }
    
    // Request a new loan
    function requestLoan(uint256 _amount, uint256 _duration) external returns (uint256) {
        require(_amount > 0, "Amount must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");
        
        loanCounter++;
        
        loans[loanCounter] = Loan({
            id: loanCounter,
            borrower: msg.sender,
            lender: address(0),
            amount: _amount,
            interestRate: 0,
            duration: _duration,
            startTime: 0,
            repaymentAmount: 0,
            isActive: false,
            isRepaid: false,
            isSanctioned: false
        });
        
        borrowerLoans[msg.sender].push(loanCounter);
        
        emit LoanRequested(loanCounter, msg.sender, _amount, _duration);
        
        return loanCounter;
    }
    
    // Lender sanctions/approves a loan and sends funds
    function sanctionLoan(uint256 _loanId, uint256 _interestRate) external payable {
        Loan storage loan = loans[_loanId];
        
        require(!loan.isSanctioned, "Loan already sanctioned");
        require(loan.borrower != address(0), "Loan does not exist");
        require(loan.borrower != msg.sender, "Cannot lend to yourself");
        require(msg.value == loan.amount, "Must send exact loan amount");
        require(_interestRate > 0 && _interestRate <= 100, "Invalid interest rate");
        
        loan.lender = msg.sender;
        loan.interestRate = _interestRate;
        loan.startTime = block.timestamp;
        loan.isActive = true;
        loan.isSanctioned = true;
        loan.repaymentAmount = loan.amount + (loan.amount * _interestRate / 100);
        
        lenderLoans[msg.sender].push(_loanId);
        
        // Transfer funds to borrower
        payable(loan.borrower).transfer(msg.value);
        
        emit LoanSanctioned(_loanId, msg.sender, _interestRate);
    }
    
    // Borrower repays the loan
    function repayLoan(uint256 _loanId) external payable onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];
        
        require(loan.isActive, "Loan is not active");
        require(!loan.isRepaid, "Loan already repaid");
        require(msg.value >= loan.repaymentAmount, "Insufficient repayment amount");
        
        loan.isRepaid = true;
        loan.isActive = false;
        
        // Transfer repayment to lender
        payable(loan.lender).transfer(loan.repaymentAmount);
        
        // Refund excess if any
        if (msg.value > loan.repaymentAmount) {
            payable(msg.sender).transfer(msg.value - loan.repaymentAmount);
        }
        
        emit LoanRepaid(_loanId, msg.sender, loan.repaymentAmount);
    }
    
    // Cancel a pending loan request (only before sanctioned)
    function cancelLoan(uint256 _loanId) external onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];
        require(!loan.isSanctioned, "Cannot cancel sanctioned loan");
        
        loan.isActive = false;
        
        emit LoanCancelled(_loanId);
    }
    
    // View functions
    function getLoan(uint256 _loanId) external view returns (Loan memory) {
        return loans[_loanId];
    }
    
    function getBorrowerLoans(address _borrower) external view returns (uint256[] memory) {
        return borrowerLoans[_borrower];
    }
    
    function getLenderLoans(address _lender) external view returns (uint256[] memory) {
        return lenderLoans[_lender];
    }
    
    function getPendingLoans() external view returns (Loan[] memory) {
        uint256 count = 0;
        
        // Count pending loans
        for (uint256 i = 1; i <= loanCounter; i++) {
            if (!loans[i].isSanctioned && loans[i].borrower != address(0)) {
                count++;
            }
        }
        
        Loan[] memory pendingLoans = new Loan[](count);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= loanCounter; i++) {
            if (!loans[i].isSanctioned && loans[i].borrower != address(0)) {
                pendingLoans[index] = loans[i];
                index++;
            }
        }
        
        return pendingLoans;
    }
    
    function getActiveLoans() external view returns (Loan[] memory) {
        uint256 count = 0;
        
        for (uint256 i = 1; i <= loanCounter; i++) {
            if (loans[i].isActive) {
                count++;
            }
        }
        
        Loan[] memory activeLoans = new Loan[](count);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= loanCounter; i++) {
            if (loans[i].isActive) {
                activeLoans[index] = loans[i];
                index++;
            }
        }
        
        return activeLoans;
    }
}
