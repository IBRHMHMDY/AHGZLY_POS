import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final double taxRate;
  final double serviceRate;
  final double deliveryFee;
  final String printerName;

  const AppSettings({
    required this.taxRate,
    required this.serviceRate,
    required this.deliveryFee,
    required this.printerName,
  });

  @override
  List<Object?> get props => [taxRate, serviceRate, deliveryFee, printerName];
}