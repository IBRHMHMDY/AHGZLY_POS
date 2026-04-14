import 'package:ahgzly_pos/core/utils/enums/enums_data.dart';
import 'package:ahgzly_pos/core/utils/extensions/order_type.dart';
import 'package:ahgzly_pos/core/utils/date_time_utils.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/orders/domain/entities/order_history_entity.dart';
// ignore: library_prefixes
import 'package:intl/intl.dart' as intlDateTime;

Widget _buildRow(String title, int valueInCents) {
  // Refactored: int
  final formattedValue = MoneyFormatter.format(valueInCents);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
      Text(
        '$formattedValue ج.م',
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    ],
  );
}

class CustomerReceiptWidget extends StatelessWidget {
  final int orderId;
  final OrderType orderType;
  final List<CartItem> items;
  final int subTotal;
  final int discountAmount;
  final int taxAmount;
  final int serviceFee;
  final int deliveryFee;
  final int total;
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
    final dateFormat = intlDateTime.DateFormat('yyyy-MM-dd hh:mm a');
    final formattedNow = dateFormat.format(DateTime.now());
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
            Text(
              restaurantName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'الرقم الضريبي: $taxNumber',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الكاشير: $cashierName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  formattedNow,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فاتورة رقم: #$orderId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  // [Refactor] استخدام دالة العرض المخصصة للـ Enum
                  'النوع: ${orderType.toDisplayName()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const Text(
              '----------------------------------------',
              style: TextStyle(color: Colors.black),
            ),
            ...items.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${c.item.name} (x${c.quantity})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${MoneyFormatter.format(c.item.price * c.quantity)} ج.م',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '----------------------------------------',
              style: TextStyle(color: Colors.black),
            ),
            _buildRow('الإجمالي الفرعي:', subTotal),
            if (discountAmount > 0) _buildRow('قيمة الخصم:', -discountAmount),
            _buildRow('الضريبة المضافة:', taxAmount),
            if (serviceFee > 0) _buildRow('رسوم الخدمة:', serviceFee),
            if (deliveryFee > 0) _buildRow('رسوم التوصيل:', deliveryFee),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'الإجمالي النهائي:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${MoneyFormatter.format(total)} ج.م',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            if (orderType == OrderType.delivery &&
                (customerName.isNotEmpty ||
                    customerPhone.isNotEmpty ||
                    customerAddress.isNotEmpty)) ...[
              const Divider(color: Colors.black, thickness: 2),
              const Text(
                'بيانات التوصيل:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (customerName.isNotEmpty)
                Text(
                  'الاسم: $customerName',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              if (customerPhone.isNotEmpty)
                Text(
                  'الهاتف: $customerPhone',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (customerAddress.isNotEmpty)
                Text(
                  'العنوان: $customerAddress',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
            ],
            const SizedBox(height: 20),
            const Text(
              'شكراً لزيارتكم!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              formattedNow,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class KitchenReceiptWidget extends StatelessWidget {
  final int orderId;
  final OrderType orderType;
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
            const Text(
              'بـون مـطـبـخ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 3),
            Text(
              'طلب رقم: #$orderId',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'النوع: ${orderType.toDisplayName()}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              '====================',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            ...items.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[ ${c.quantity} ]  ',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c.item.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '====================',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              DateTime.now().toString().substring(0, 16),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerHistoryReceiptWidget extends StatelessWidget {
  final OrderHistoryEntity order;
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
            Text(
              restaurantName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'الرقم الضريبي: $taxNumber',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const Text(
              '*** نسخة مُعاد طباعتها ***',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فاتورة رقم: #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'النوع: ${order.orderType.toDisplayName()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Text(
              '----------------------------------------',
              style: TextStyle(color: Colors.black),
            ),
            ...order.items.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${i.itemName} (x${i.quantity})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${MoneyFormatter.format(i.unitPrice * i.quantity)} ج.م',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '----------------------------------------',
              style: TextStyle(color: Colors.black),
            ),
            _buildRow('الإجمالي الفرعي:', order.subTotal),
            if (order.discount > 0) _buildRow('قيمة الخصم:', -order.discount),
            const Divider(color: Colors.black, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي النهائي:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${MoneyFormatter.format(order.total)} ج.م',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              DateTime.parse(order.createdAt.toDisplayDate()).toString().substring(0, 16),
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class ZReportReceiptWidget extends StatelessWidget {
  final ShiftEntity shift;
  final String restaurantName;
  final String cashierName;
  final bool isXReport;

  const ZReportReceiptWidget({
    super.key,
    required this.shift,
    required this.restaurantName,
    required this.cashierName,
    this.isXReport = false,
  });

  @override
  Widget build(BuildContext context) {
    final isShortage = shift.shortageOrOverage < 0;
    final diffLabel = isShortage
        ? 'عجز في الدرج:'
        : (shift.shortageOrOverage > 0 ? 'زيادة في الدرج:' : 'مطابقة تامة:');

    final dateFormat = intlDateTime.DateFormat('yyyy-MM-dd hh:mm a');
    final startTimeFormatted = dateFormat.format(shift.startTime);
    final endTimeFormatted = shift.endTime != null
        ? dateFormat.format(shift.endTime!)
        : dateFormat.format(DateTime.now());

    final String reportTitle = isXReport
        ? 'ملخص مبيعات الوردية (X-Report)'
        : 'تقرير إغلاق الوردية (Z-Report)';

    // 🪄 تغليف الكود بـ Material يمنع تحطم ScreenshotController عند تحويل الـ Widget لصورة
    return Material(
      color: Colors.white,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                restaurantName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                reportTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const Divider(color: Colors.black, thickness: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('بداية الوردية:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(startTimeFormatted, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isXReport ? 'وقت الطباعة:' : 'نهاية الوردية:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(endTimeFormatted, style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),

              const Divider(color: Colors.black, thickness: 2),
              _buildRow('العهدة الافتتاحية:', shift.startingCash),
              _buildRow('إجمالي المبيعات:', shift.totalSales),
              _buildRow('مبيعات الكاش:', shift.totalCash),
              _buildRow('مبيعات الفيزا:', shift.totalVisa),
              _buildRow('مبيعات إنستاباي:', shift.totalInstapay),
              const Divider(color: Colors.black, thickness: 1),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('عدد طلبات المرتجع:', style: TextStyle(fontSize: 16, color: Colors.black)),
                  // 🪄 تم إصلاح الخطأ المنطقي: استخدام refundedOrdersCount بدلاً من totalOrders
                  Text('${shift.refundedOrdersCount}', style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
              _buildRow('إجمالي المرتجعات:', shift.totalRefunds),
              const Divider(color: Colors.black, thickness: 1),
              _buildRow('إجمالي المصروفات:', shift.totalExpenses),
              const Divider(color: Colors.black, thickness: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('النقدية المتوقعة:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${MoneyFormatter.format(shift.expectedCash)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ],
              ),

              if (!isXReport) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('النقدية الفعلية:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${MoneyFormatter.format(shift.actualCash)} ج.م', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
                const Divider(color: Colors.black, thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(diffLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('${MoneyFormatter.format(shift.shortageOrOverage.abs())} ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ],

              const Divider(color: Colors.black, thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي عدد الطلبات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('${shift.totalOrders}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الكاشير:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text(cashierName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text('توقيع المـديـر: ..................................', style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 20),
              Text('طُبع في: ${dateFormat.format(DateTime.now())}', style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
