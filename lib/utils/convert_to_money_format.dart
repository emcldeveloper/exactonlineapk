import 'package:money_formatter/money_formatter.dart';

String toMoneyFormmat(dynamic price) {
  double amount;

  if (price is int) {
    amount = price.toDouble();
  } else if (price is String) {
    amount = double.tryParse(price) ?? 0.0;
  } else {
    amount = 0.0;
  }

  return MoneyFormatter(amount: amount).output.withoutFractionDigits;
}
