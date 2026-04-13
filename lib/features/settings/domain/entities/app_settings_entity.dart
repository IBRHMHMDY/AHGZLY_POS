import 'package:equatable/equatable.dart';

class AppSettingsEntity extends Equatable {
  final double taxRate; // تبقى double لأنها نسبة
  final double serviceRate; // تبقى double لأنها نسبة
  final int deliveryFee; // Refactored: تغيير من double إلى int (Cents)
  final String printerName;
  final String restaurantName;
  final String taxNumber;
  final String printMode;

  const AppSettingsEntity({
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