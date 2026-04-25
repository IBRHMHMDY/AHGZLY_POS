import 'package:ahgzly_pos/core/di/modular/init_auth.dart';
import 'package:ahgzly_pos/core/di/modular/init_core.dart';
import 'package:ahgzly_pos/core/di/modular/init_expenses.dart';
import 'package:ahgzly_pos/core/di/modular/init_license.dart';
import 'package:ahgzly_pos/core/di/modular/init_menu.dart';
import 'package:ahgzly_pos/core/di/modular/init_orders.dart';
import 'package:ahgzly_pos/core/di/modular/init_pos.dart';
import 'package:ahgzly_pos/core/di/modular/init_settings.dart';
import 'package:ahgzly_pos/core/di/modular/init_shift.dart';
import 'package:ahgzly_pos/core/di/modular/init_users.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  initCore();
  initLicense();
  initAuth();
  initMenu();
  initShift();
  initPos();
  initSettings();
  initOrders();
  initExpenses();
  initUsers();
}


