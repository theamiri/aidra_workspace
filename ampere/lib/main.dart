import 'dart:io';
import 'package:ampere/ampere_app.dart';
import 'package:ampere/core/config/env_config.dart';
import 'package:ampere/core/injection/injection.dart';
import 'package:ampere/core/storage/hive_adapters.dart';
import 'package:ampere/core/utils/http_overrider.dart';
import 'package:flutter/material.dart';

void main() async {
  // init WidgetsFlutterBinding if not yet
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await EnvConfig.initialize();

  // Initialize Hive (must be done before dependency injection)
  await HiveAdapters.init();

  // Initialize HTTP overrides (only in development for SSL certificate bypass)
  // WARNING: This should only be enabled in development, not production
  if (!EnvConfig.isProduction) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Initialize dependency injection
  await initializeDependencies();

  // Run the app
  runApp(const AmpereApp());
}

