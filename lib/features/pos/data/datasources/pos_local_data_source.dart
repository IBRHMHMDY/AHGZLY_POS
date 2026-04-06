import 'package:ahgzly_pos/core/database/database_helper.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_item_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class PosLocalDataSource {
  Future<int> saveOrder(OrderModel order);
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final DatabaseHelper databaseHelper;

  PosLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<int> saveOrder(OrderModel order) async {
    final db = await databaseHelper.database;
    
    try {
      // استخدام Transaction صارم يحقق مبدأ الـ ACID (Atomicity, Consistency, Isolation, Durability)
      return await db.transaction((txn) async {
        
        // 1. التحقق من وجود وردية نشطة أولاً (يجب أن يحتوي الـ order على shift_id)
        if (order.shiftId == null || order.shiftId == 0) {
            throw CacheException(message: 'لا يمكن إتمام البيع: لا توجد وردية نشطة محددة.');
        }

        // 2. إدخال الطلب الأساسي (الفاتورة)
        final orderMap = order.toMap();
        final orderId = await txn.insert(
          'orders', 
          orderMap,
          conflictAlgorithm: ConflictAlgorithm.fail, // تجنب الكتابة فوق بيانات أخرى
        );

        // 3. إدخال الأصناف التابعة لهذه الفاتورة
        if (order.items.isEmpty) {
          throw CacheException(message: 'لا يمكن حفظ فاتورة فارغة.');
        }

        for (var item in order.items) {
          final itemModel = item as OrderItemModel;
          final itemMap = itemModel.toMap();
          itemMap['order_id'] = orderId; 
          
          await txn.insert(
            'order_items', 
            itemMap,
            conflictAlgorithm: ConflictAlgorithm.fail,
          );
        }

        // 4. تحديث إحصائيات الوردية (Shifts) في نفس الـ Transaction لضمان سلامة الأموال
        // ملاحظة: يتم الاعتماد على طريقة الدفع لتحديث الحقل المناسب في الوردية
        String paymentColumn = 'total_cash';
        if (order.paymentMethod.toLowerCase() == 'visa') paymentColumn = 'total_visa';
        if (order.paymentMethod.toLowerCase() == 'instapay') paymentColumn = 'total_instapay';

        await txn.rawUpdate('''
          UPDATE shifts 
          SET total_sales = total_sales + ?, 
              $paymentColumn = $paymentColumn + ?, 
              expected_cash = expected_cash + ?, 
              total_orders = total_orders + 1 
          WHERE id = ? AND status = 'active'
        ''', [
          order.total, 
          order.total, 
          (paymentColumn == 'total_cash' ? order.total : 0.0), // الكاش المتوقع يزيد فقط إذا كان الدفع نقدي
          order.shiftId
        ]);

        return orderId;
      });
    } catch (e) {
      // التقاط الأخطاء وإرسالها كاستثناء موحد للـ Repository ليحوله إلى Failure
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message:'حدث خطأ غير متوقع أثناء حفظ الفاتورة: ${e.toString()}');
    }
  }
}