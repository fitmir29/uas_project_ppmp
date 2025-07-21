class Income {
  final int? id;
  final String source;
  final double amount;
  final String date;

  Income({
    this.id,
    required this.source,
    required this.amount,
    required this.date,
  });

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        source: json['source'],
        amount: (json['amount'] as num).toDouble(), // penting
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        'source': source,
        'amount': amount,
        'date': date,
      };
}
