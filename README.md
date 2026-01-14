# 💰 Loan DApp

A decentralized peer-to-peer lending application built with Flutter and Ethereum smart contracts. Users can request loans, fund loan requests, and manage repayments - all on the blockchain!

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Solidity](https://img.shields.io/badge/Solidity-0.8.x-363636?logo=solidity)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **🔐 Wallet Connection** - Connect using your Ethereum private key
- **📝 Request Loans** - Create loan requests specifying amount and duration
- **💸 Fund Loans** - Browse and fund pending loan requests from other users
- **📊 Dashboard** - View your wallet balance and recent activity
- **🔄 Repay Loans** - Repay your borrowed loans with interest
- **📱 Cross-Platform** - Works on iOS, Android, macOS, Windows, Linux, and Web

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.x, Dart
- **Blockchain**: Ethereum (Ganache for local development)
- **Smart Contract**: Solidity 0.8.x
- **Web3**: web3dart, wallet packages

## 📋 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- [Ganache](https://trufflesuite.com/ganache/) - Local Ethereum blockchain
- [Remix IDE](https://remix.ethereum.org) - For contract deployment

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Uday1772002/loan_Dapp.git
cd loan_Dapp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Start Ganache

- Download and install [Ganache](https://trufflesuite.com/ganache/)
- Create a new workspace
- Ensure it's running on `http://localhost:7545` (default)

### 4. Deploy the Smart Contract

1. Open [Remix IDE](https://remix.ethereum.org)
2. Create a new file and paste the contents of `contracts/LoanContract.sol`
3. Compile the contract (Solidity 0.8.x)
4. In "Deploy & Run Transactions":
   - Set Environment to **"Custom - External Http Provider"**
   - Enter `http://localhost:7545`
   - Click **Deploy**
5. Copy the deployed contract address

### 5. Run the App

```bash
flutter run
```

### 6. Connect Your Wallet

1. Open the app
2. Enter a **Private Key** from Ganache (click the key icon next to any account)
3. Enter the **Contract Address** from step 4
4. Tap **Connect Wallet**

## 📱 Screenshots

|  Connect Wallet   |        Dashboard        |    Request Loan     |
| :---------------: | :---------------------: | :-----------------: |
| Enter credentials | View balance & activity | Create loan request |

|       Fund Loans       |       My Loans       |
| :--------------------: | :------------------: |
| Browse & fund requests | Manage borrowed/lent |

## 📁 Project Structure

```
loan_Dapp/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── loan.dart             # Loan data model
│   ├── screens/
│   │   ├── connect_wallet_screen.dart
│   │   ├── home_screen.dart
│   │   ├── request_loan_screen.dart
│   │   ├── sanction_loan_screen.dart
│   │   └── my_loans_screen.dart
│   ├── services/
│   │   └── web3_service.dart     # Blockchain interactions
│   └── theme/
│       └── app_theme.dart        # App styling
├── contracts/
│   └── LoanContract.sol          # Solidity smart contract
├── assets/
│   └── abi.json                  # Contract ABI
└── pubspec.yaml
```

## 🔧 Smart Contract Functions

| Function                             | Description                       |
| ------------------------------------ | --------------------------------- |
| `requestLoan(amount, duration)`      | Create a new loan request         |
| `sanctionLoan(loanId, interestRate)` | Fund a loan request               |
| `repayLoan(loanId)`                  | Repay borrowed loan with interest |
| `cancelLoan(loanId)`                 | Cancel your pending loan request  |
| `getLoan(loanId)`                    | Get loan details                  |
| `getBorrowerLoans(address)`          | Get all loans for a borrower      |
| `getLenderLoans(address)`            | Get all loans funded by a lender  |

## ⚠️ Important Notes

- This is a **development/testing** application using Ganache test ETH
- **Never use real private keys** - Ganache provides test accounts
- The contract has no access control - anyone can lend/borrow
- Interest calculation uses simple arithmetic (no compounding)

## 🐛 Troubleshooting

### "Gas estimation failed" in Remix

- Try clicking "Send Transaction" anyway
- Increase Gas Limit to 3,000,000
- Use Remix VM first to verify contract works

### "Connection refused" error

- Ensure Ganache is running on port 7545
- Check firewall settings

### Contract not found

- Verify you copied the correct contract address
- Ensure the contract is deployed to the same network

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ using Flutter & Ethereum
