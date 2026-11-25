import 'package:logger/logger.dart';

final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 4,
    lineLength: 90,
    colors: false,
    printEmojis: false,
  ),
);
