import 'package:flutter/foundation.dart';

@immutable
abstract class ShiftEvent {}

class CheckActiveShiftEvent extends ShiftEvent {}

class OpenShiftSubmittedEvent extends ShiftEvent {
  final int startingCash;
  final int cashierId;
  OpenShiftSubmittedEvent({required this.startingCash, required this.cashierId});
}

class CloseShiftSubmittedEvent extends ShiftEvent {
  final int shiftId;
  final double actualCash;
  CloseShiftSubmittedEvent({required this.shiftId, required this.actualCash});
}