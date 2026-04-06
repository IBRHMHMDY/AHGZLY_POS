import 'package:ahgzly_pos/features/shift/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';

Widget _buildRow(String title, double value) {
  // إجبار الرقم على عرض خانتين عشريتين فقط للعملة
  final formattedValue = value.toStringAsFixed(2);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
      Text('$formattedValue ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
    ],
  );
}

class CustomerReceiptWidget extends StatelessWidget {
  final int orderId;
  final String orderType;
  final List<CartItem> items;
  final double subTotal;
  final double discountAmount;
  final double taxAmount;
  final double serviceFee;
  final double deliveryFee;
  final double total;
  final String restaurantName;
  final String taxNumber;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String cashierName;

  const CustomerReceiptWidget({
    super.key,
    required this.orderId,
    required this.orderType,
    required this.items,
    required this.subTotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
    required this.restaurantName,
    required this.taxNumber,
    required this.cashierName,
    this.customerName = '',
    this.customerPhone = '',
    this.customerAddress = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(restaurantName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('الرقم الضريبي: $taxNumber', style: const TextStyle(fontSize: 14, color: Colors.black)),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب رقم: #$orderId', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('النوع: $orderType', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            ...items.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${c.item.name} (x${c.quantity})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
                      Text('${(c.item.price * c.quantity).toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                )),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            _buildRow('الإجمالي الفرعي:', subTotal),
            if (discountAmount > 0) _buildRow('قيمة الخصم:', -discountAmount),
            _buildRow('الضريبة المضافة:', taxAmount),
            if (serviceFee > 0) _buildRow('رسوم الخدمة:', serviceFee),
            if (deliveryFee > 0) _buildRow('رسوم التوصيل:', deliveryFee),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي النهائي:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('$total ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            if (orderType == 'دليفري' && (customerName.isNotEmpty || customerPhone.isNotEmpty || customerAddress.isNotEmpty)) ...[
              const Divider(color: Colors.black, thickness: 2),
              const Text('بيانات التوصيل:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              if (customerName.isNotEmpty) Text('الاسم: $customerName', style: const TextStyle(fontSize: 16, color: Colors.black)),
              if (customerPhone.isNotEmpty) Text('الهاتف: $customerPhone', style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
              if (customerAddress.isNotEmpty) Text('العنوان: $customerAddress', style: const TextStyle(fontSize: 16, color: Colors.black)),
            ],
            const SizedBox(height: 20),
            const Text('شكراً لزيارتكم!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 14, color: Colors.black)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الكاشير: $cashierName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class KitchenReceiptWidget extends StatelessWidget {
  final int orderId;
  final String orderType;
  final List<CartItem> items;
  
  const KitchenReceiptWidget({
    super.key,
    required this.orderId,
    required this.orderType,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('بـون مـطـبـخ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(color: Colors.black, thickness: 3),
            Text('طلب رقم: #$orderId', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('النوع: $orderType', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const Text('====================', style: TextStyle(fontSize: 20, color: Colors.black)),
            ...items.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('[ ${c.quantity} ]  ', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                      Expanded(child: Text(c.item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
                    ],
                  ),
                )),
            const Text('====================', style: TextStyle(fontSize: 20, color: Colors.black)),
            Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class CustomerHistoryReceiptWidget extends StatelessWidget {
  final OrderHistory order;
  final String restaurantName;
  final String taxNumber;
  
  const CustomerHistoryReceiptWidget({
    super.key,
    required this.order,
    required this.restaurantName,
    required this.taxNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(restaurantName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('الرقم الضريبي: $taxNumber', style: const TextStyle(fontSize: 14, color: Colors.black)),
            const Text('*** نسخة مُعاد طباعتها ***', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب رقم: #${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('النوع: ${order.orderType}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            ...order.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${i.itemName} (x${i.quantity})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
                      Text('${(i.unitPrice * i.quantity).toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                )),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            _buildRow('الإجمالي الفرعي:', order.subTotal),
            if (order.discount > 0) _buildRow('قيمة الخصم:', -order.discount),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي النهائي:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${order.total.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            Text(DateTime.parse(order.createdAt).toString().substring(0, 16), style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class ZReportReceiptWidget extends StatelessWidget {
  final Shift shift; // تم التحديث لـ Shift
  final String restaurantName;
  
  const ZReportReceiptWidget({
    super.key,
    required this.shift,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    final isShortage = shift.shortageOrOverage < 0;
    final diffLabel = isShortage ? 'عجز في الدرج:' : (shift.shortageOrOverage > 0 ? 'زيادة في الدرج:' : 'مطابقة تامة:');

    return Container(
      width: 350,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(restaurantName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Text('تقرير إغلاق الوردية (Z-Report)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(color: Colors.black, thickness: 2),
            const SizedBox(height: 10),
            _buildRow('العهدة الافتتاحية:', shift.startingCash),
            _buildRow('إجمالي المبيعات:', shift.totalSales),
            _buildRow('مبيعات الكاش:', shift.totalCash),
            _buildRow('مبيعات الفيزا:', shift.totalVisa),
            _buildRow('مبيعات إنستاباي:', shift.totalInstapay),
            const Divider(color: Colors.black, thickness: 1),
            _buildRow('إجمالي المصروفات:', shift.totalExpenses),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('النقدية المتوقعة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${shift.expectedCash.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('النقدية الفعلية:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${shift.actualCash.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(diffLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${shift.shortageOrOverage.abs().toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي عدد الطلبات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${shift.totalOrders}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('توقيع الكاشير: ........................', style: TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 10),
            const Text('توقيع المـديـر: ........................', style: TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 20),
            Text('وقت الطباعة: ${DateTime.now().toString().substring(0, 16)}', style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}