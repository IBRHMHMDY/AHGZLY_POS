class SupplierInvoiceSummary {
  final int id;
  final int totalAmount;
  final int paidAmount;
  final DateTime invoiceDate;
  final String? notes;

  int get remaining => totalAmount - paidAmount;

  SupplierInvoiceSummary({
    required this.id,
    required this.totalAmount,
    required this.paidAmount,
    required this.invoiceDate,
    this.notes,
  });
}

class SupplierReportModel {
  final int supplierId;
  final String supplierName;
  final String? supplierPhone;
  final int totalPurchases;
  final int totalPaid;
  final List<SupplierInvoiceSummary> invoices;

  int get totalRemaining => totalPurchases - totalPaid;

  SupplierReportModel({
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    required this.totalPurchases,
    required this.totalPaid,
    required this.invoices,
  });
}
