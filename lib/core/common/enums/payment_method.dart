enum PaymentMethod {
  cash('كاش'),
  visa('فيزا'),
  wallet('محفظة / إنستاباي'),
  unpaid('آجل / لم يُدفع');

  final String arabicName;
  const PaymentMethod(this.arabicName);

  static PaymentMethod fromString(String name) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == name,
      orElse: () => PaymentMethod.cash, 
    );
  }
}