import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:drift/drift.dart';
import '../../../../shared/data/models/customer_model.dart';

abstract class CustomersLocalDataSource {
  Future<List<CustomerModel>> getCustomers({String? searchQuery});
  Future<CustomerModel> addCustomer(CustomersCompanion customer);
  Future<CustomerModel> updateCustomer(CustomersCompanion customer);
  Future<void> deleteCustomer(int id);
  Future<CustomerModel?> getCustomerByPhone(String phone);
  Future<CustomerDetailModel> getCustomerDetail(int customerId);
}

class CustomersLocalDataSourceImpl implements CustomersLocalDataSource {
  final AppDatabase db;

  CustomersLocalDataSourceImpl({required this.db});

  @override
  Future<List<CustomerModel>> getCustomers({String? searchQuery}) async {
    try {
      final query = db.select(db.customers)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.where((t) => t.name.contains(searchQuery) | t.phone.contains(searchQuery));
      }

      final customers = await query.get();
      return customers.map((c) => CustomerModel.fromDrift(c)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب العملاء: $e');
    }
  }

  @override
  Future<CustomerModel> addCustomer(CustomersCompanion customer) async {
    try {
      final id = await db.into(db.customers).insert(customer);
      final data = await (db.select(db.customers)..where((t) => t.id.equals(id))).getSingle();
      return CustomerModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في إضافة العميل: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomersCompanion customer) async {
    try {
      await db.update(db.customers).replace(customer);
      final data = await (db.select(db.customers)..where((t) => t.id.equals(customer.id.value))).getSingle();
      return CustomerModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في تحديث بيانات العميل: $e');
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    try {
      await (db.delete(db.customers)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw CacheException('فشل في حذف العميل: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      final result = await (db.select(db.customers)..where((t) => t.phone.equals(phone))).getSingleOrNull();
      return result != null ? CustomerModel.fromDrift(result) : null;
    } catch (e) {
      throw CacheException('فشل في البحث بالهاتف: $e');
    }
  }

  @override
  Future<CustomerDetailModel> getCustomerDetail(int customerId) async {
    try {
      final customer = await (db.select(db.customers)..where((t) => t.id.equals(customerId))).getSingle();

      final ordersResult = await db.customSelect(
        """
        SELECT o.id, o.total, o.status, o.order_type, o.created_at,
               COUNT(oi.id) as items_count
        FROM orders o
        LEFT JOIN order_items oi ON oi.order_id = o.id
        WHERE o.customer_id = $customerId AND o.status = 'completed'
        GROUP BY o.id
        ORDER BY o.created_at DESC
        LIMIT 20
        """,
        readsFrom: {db.orders, db.orderItems},
      ).get();

      final totalSpent = ordersResult.fold<int>(0, (s, r) => s + (r.data['total'] as int? ?? 0));
      final totalOrders = ordersResult.length;

      final recentOrders = ordersResult.map((r) => CustomerOrderSummary(
        id: r.data['id'] as int,
        total: r.data['total'] as int? ?? 0,
        itemsCount: r.data['items_count'] as int? ?? 0,
        orderType: r.data['order_type'] as String? ?? 'takeaway',
        createdAt: DateTime.parse(r.data['created_at'] as String),
      )).toList();

      return CustomerDetailModel(
        customer: CustomerModel.fromDrift(customer),
        totalSpent: totalSpent,
        totalOrders: totalOrders,
        recentOrders: recentOrders,
        avgOrderValue: totalOrders > 0 ? totalSpent ~/ totalOrders : 0,
      );
    } catch (e) {
      throw CacheException('فشل في جلب تفاصيل العميل: $e');
    }
  }
}
