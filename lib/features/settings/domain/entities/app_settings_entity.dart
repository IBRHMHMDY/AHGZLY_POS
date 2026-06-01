import 'package:ahgzly_pos/core/extensions/print_mode.dart';
import 'package:equatable/equatable.dart';

class AppSettingsEntity extends Equatable {
  final double taxRate; 
  final double serviceRate; 
  final int deliveryFee; 
  final String printerName;
  final String restaurantName;
  final String taxNumber;
  final PrintMode printMode; // [Refactored]: تغيير من String إلى Enum

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