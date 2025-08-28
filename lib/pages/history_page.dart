import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/transaction_model.dart';
import 'package:money_tracker/utils/colors.dart';

class HistoryPage extends StatelessWidget {
  final List<Transaction> transactions;
  const HistoryPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          "All Transactions",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? Center(
              child: Text(
                "No transactions to show.",
                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final bool isIncome = tx.type == TransactionType.income;

                return Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.05),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    title: Text(
                      tx.description,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(tx.date)}, ${DateFormat.jm().format(tx.date)}',
                      style: GoogleFonts.poppins(color: AppColors.grey),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${isIncome ? '+' : '-'} ${currencyFormatter.format(tx.amount)}",
                          style: GoogleFonts.poppins(
                            color: isIncome ? AppColors.green : AppColors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isIncome ? 'Income' : 'Expenses',
                          style: GoogleFonts.poppins(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
