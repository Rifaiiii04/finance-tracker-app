import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/utils/colors.dart';
import 'package:finance_tracker/models/transaction_model.dart';

class HomePage extends StatefulWidget {
  final List<Transaction> transactions;
  const HomePage({super.key, required this.transactions});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  double _totalBalance = 0.0;
  double _initialBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions != oldWidget.transactions) {
      _calculateTotalBalance();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _initialBalance = prefs.getDouble('initialBalance') ?? 0.0;
      _calculateTotalBalance();
    });
  }

  void _calculateTotalBalance() {
    double income = widget.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
    double expense = widget.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
    setState(() {
      _totalBalance = _initialBalance + income - expense;
    });
  }

  // <<< FUNGSI UNTUK DATA CHART TETAP SAMA >>>
  Map<int, double> _getDailyTotals(TransactionType type) {
    Map<int, double> dailyTotals = {};
    final filteredTransactions = widget.transactions.where((tx) {
      final daysAgo = DateTime.now().difference(tx.date).inDays;
      return tx.type == type && daysAgo < 7;
    }).toList();

    for (var tx in filteredTransactions) {
      int dayOfWeek = tx.date.weekday; // Mon=1, Sun=7
      dailyTotals[dayOfWeek] = (dailyTotals[dayOfWeek] ?? 0) + tx.amount;
    }
    return dailyTotals;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildBalanceCard(currencyFormatter),
              const SizedBox(height: 30),
              _buildChartSection(), // Chart yang sudah diperbaiki
              const SizedBox(height: 30),
              _buildRecentTransactions(currencyFormatter),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/logo.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(), // <-- Ganti di sini
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
            Text(
              _userName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(NumberFormat currencyFormatter) {
    double todayChange = widget.transactions
        .where((tx) => tx.date.day == DateTime.now().day)
        .fold(0, (prev, tx) {
          return prev +
              (tx.type == TransactionType.income ? tx.amount : -tx.amount);
        });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance",
            style: GoogleFonts.poppins(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(_totalBalance),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                (todayChange >= 0 ? "+ " : "") +
                    currencyFormatter.format(todayChange),
                style: GoogleFonts.poppins(color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // <<< WIDGET CHART YANG DIPERBARUI TOTAL >>>
  Widget _buildChartSection() {
    final incomeData = _getDailyTotals(TransactionType.income);
    final expenseData = _getDailyTotals(TransactionType.expense);

    // Cari nilai maksimal untuk menentukan skala Y-Axis
    double maxAmount = 0;
    incomeData.values.forEach((amount) => maxAmount = max(maxAmount, amount));
    expenseData.values.forEach((amount) => maxAmount = max(maxAmount, amount));
    if (maxAmount == 0) maxAmount = 100000; // Default value if no transactions

    List<FlSpot> incomeSpots = List.generate(7, (index) {
      int day = index + 1;
      return FlSpot(day.toDouble(), incomeData[day] ?? 0);
    });
    List<FlSpot> expenseSpots = List.generate(7, (index) {
      int day = index + 1;
      return FlSpot(day.toDouble(), expenseData[day] ?? 0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Income Vs Expenses",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Legend
        Row(
          children: [
            _buildLegendItem(AppColors.green, "Income"),
            const SizedBox(width: 16),
            _buildLegendItem(AppColors.red, "Expenses"),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              // Tooltip Interaktif saat disentuh
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      String text;
                      if (flSpot.barIndex == 0) {
                        // Income
                        text = 'Income: ';
                      } else {
                        // Expense
                        text = 'Expense: ';
                      }
                      text += NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(flSpot.y);

                      return LineTooltipItem(
                        text,
                        TextStyle(
                          color:
                              flSpot.bar.gradient?.colors.first ??
                              flSpot.bar.color ??
                              Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              // Garis Grid Horizontal
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1);
                },
              ),
              // Judul Axis (X dan Y)
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value >= maxAmount * 1.1)
                        return const SizedBox();
                      return Text(
                        NumberFormat.compact(locale: 'id_ID').format(value),
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 1:
                          text = const Text('Mon', style: style);
                          break;
                        case 2:
                          text = const Text('Tue', style: style);
                          break;
                        case 3:
                          text = const Text('Wed', style: style);
                          break;
                        case 4:
                          text = const Text('Thu', style: style);
                          break;
                        case 5:
                          text = const Text('Fri', style: style);
                          break;
                        case 6:
                          text = const Text('Sat', style: style);
                          break;
                        case 7:
                          text = const Text('Sun', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: text,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              // Set nilai maksimal Y axis agar ada ruang di atas
              maxY: maxAmount * 1.2,
              // Data Garis
              lineBarsData: [
                // Garis Income (Hijau)
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.green, Colors.lightGreen],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.green.withOpacity(0.3),
                        AppColors.green.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Garis Expense (Merah)
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.red, Colors.orange],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.red.withOpacity(0.3),
                        AppColors.red.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(NumberFormat currencyFormatter) {
    final recentTransactions = widget.transactions.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "View All",
                style: GoogleFonts.poppins(color: AppColors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "No transactions yet.",
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = recentTransactions[index];
              final isIncome = tx.type == TransactionType.income;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  title: Text(
                    tx.description,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    DateFormat('hh:mm a').format(tx.date),
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Text(
                    "${isIncome ? '+' : '-'} ${currencyFormatter.format(tx.amount)}",
                    style: GoogleFonts.poppins(
                      color: isIncome ? AppColors.green : AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
