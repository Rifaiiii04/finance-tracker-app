import 'package:flutter/material.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/history_page.dart';
import 'package:money_tracker/utils/colors.dart';
import 'package:money_tracker/widgets/add_transaction_modal.dart';
import 'package:money_tracker/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTransactions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> transactionsJson =
        prefs.getStringList('transactions') ?? [];
    setState(() {
      _transactions = transactionsJson
          .map((json) => Transaction.fromJson(json))
          .toList();
      _transactions.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort newest first
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _addTransaction(Transaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> transactionsJson =
        prefs.getStringList('transactions') ?? [];
    transactionsJson.add(transaction.toJson());
    await prefs.setStringList('transactions', transactionsJson);
    _loadTransactions();
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddTransactionModal(
          onAdd: (transaction) {
            _addTransaction(transaction);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          HomePage(transactions: _transactions),
          HistoryPage(transactions: _transactions),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTransactionModal,
              backgroundColor: AppColors.green,
              child: const Icon(Icons.add, color: AppColors.white),
              shape: const CircleBorder(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? AppColors.green : AppColors.grey,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: _selectedIndex == 1 ? AppColors.green : AppColors.grey,
                ),
                onPressed: () => _onItemTapped(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
