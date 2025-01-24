import 'package:money_formatter/money_formatter.dart';

String toMoneyFormmat (String price){
  return MoneyFormatter(amount: double.parse(price)).output.withoutFractionDigits;
}