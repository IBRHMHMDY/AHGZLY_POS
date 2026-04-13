import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettingsEntity settings;
  
  // Refactored: Changed to Named Parameter
  const SettingsLoaded({required this.settings});
  
  @override
  List<Object> get props => [settings];
}

class SettingsSavedSuccess extends SettingsState {
  final String message;
  
  // Refactored: Changed to accept a String message instead of AppSettings object
  const SettingsSavedSuccess({required this.message});
  
  @override
  List<Object> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;
  
  // Refactored: Changed to Named Parameter
  const SettingsError({required this.message});
  
  @override
  List<Object> get props => [message];
}