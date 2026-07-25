import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

String formatPrice(double amount) => _currencyFormat.format(amount);

final DateFormat _dateFormat = DateFormat('MMM d, y • h:mm a');

String formatDate(DateTime date) => _dateFormat.format(date);
