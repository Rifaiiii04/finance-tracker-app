import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/utils/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransactionModal extends StatefulWidget {
  final Function(Transaction) onAdd;

  const AddTransactionModal({super.key, required this.onAdd});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  void _formatAmount() {
    String text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      _amountController.value = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }
    final number = int.parse(text);
    final newText = _currencyFormatter.format(number);
    _amountController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    // Ambil angka saja dari input
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);
    final description = _descriptionController.text;

    if (amount == null || amount <= 0 || description.isEmpty) {
      return;
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    widget.onAdd(newTransaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Transaction",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ToggleButtons(
            isSelected: [
              _selectedType == TransactionType.expense,
              _selectedType == TransactionType.income,
            ],
            onPressed: (index) {
              setState(() {
                _selectedType = index == 0
                    ? TransactionType.expense
                    : TransactionType.income;
              });
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: AppColors.white,
            fillColor: _selectedType == TransactionType.expense
                ? AppColors.red
                : AppColors.green,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Expense", style: GoogleFonts.poppins()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Income", style: GoogleFonts.poppins()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount",
              prefixText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Add",
                style: GoogleFonts.poppins(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
