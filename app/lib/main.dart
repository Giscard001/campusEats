import 'package:flutter/material.dart';
import 'package:campuseats/app.dart';
import 'package:campuseats/core/config/app_config.dart';
import 'package:campuseats/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration from environment or default to mock mode
  final config = AppConfig.fromEnvironment();

  // Initialize all dependencies
  await initDependencies(config: config);

  runApp(const AppRoot());
}
