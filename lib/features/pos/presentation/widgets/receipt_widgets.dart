import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history.dart';

// ==========================================
// 1. فاتورة العميل الحالية (من شاشة الكاشير)
// ==========================================
class CustomerReceiptWidget extends StatelessWidget {
  final int orderId;
  final String orderType;
  final List<CartItem> items;
  final double subTotal;
  final double taxAmount;
  final double serviceFee;
  final double deliveryFee;
  final double total;
  final String restaurantName;
  final String taxNumber;

  const CustomerReceiptWidget({
    super.key,
    required this.orderId,
    required this.orderType,
    required this.items,
    required this.subTotal,
    required this.taxAmount,
    required this.serviceFee,
    required this.deliveryFee,
    required this.total,
    required this.restaurantName,
    required this.taxNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
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
            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب رقم: #$orderId', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('النوع: $orderType', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            ...items.map((cartItem) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${cartItem.item.name} (x${cartItem.quantity})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
                      Text('${cartItem.item.price * cartItem.quantity} ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                )),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            _buildRow('الإجمالي الفرعي:', subTotal),
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
            const SizedBox(height: 20),
            const Text('شكراً لزيارتكم!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
        Text('$value ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}

// ==========================================
// 2. فاتورة بون المطبخ (بدون أسعار)
// ==========================================
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
      width: 380,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('بـون مـطـبـخ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 3),
            Text('طلب رقم: #$orderId', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('النوع: $orderType', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const Text('====================', style: TextStyle(fontSize: 20, color: Colors.black)),
            ...items.map((cartItem) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('[ ${cartItem.quantity} ]  ', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                      Expanded(
                        child: Text(cartItem.item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
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

// ==========================================
// 3. فاتورة إعادة الطباعة (من سجل الطلبات)
// ==========================================
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
      width: 380,
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
            const SizedBox(height: 10),
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
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.itemName} (x${item.quantity})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
                      Text('${item.unitPrice * item.quantity} ج.م', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                )),
            const Text('----------------------------------------', style: TextStyle(color: Colors.black)),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي النهائي:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('${order.total} ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('شكراً لزيارتكم!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}