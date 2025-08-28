import 'dart:convert';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));
}
