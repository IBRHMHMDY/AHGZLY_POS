import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final double taxRate;
  final double serviceRate;
  final double deliveryFee;
  final String printerName;
  final String restaurantName;
  final String taxNumber;
  final String printMode; // المتغير الجديد

  const AppSettings({
    required this.taxRate,
    required this.serviceRate,
    required this.deliveryFee,
    required this.printerName,
    required this.restaurantName,
    required this.taxNumber,
    required this.printMode,
  });

  @override
  List<Object?> get props => [taxRate, serviceRate, deliveryFee, printerName, restaurantName, taxNumber, printMode];
}