import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campuseats/core/di/injection.dart';
import 'package:campuseats/core/router/app_router.dart';
import 'package:campuseats/core/theme/app_theme.dart';
import 'package:campuseats/features/auth/presentation/bloc/auth_bloc.dart';

class CampusEatsApp extends StatefulWidget {
  const CampusEatsApp({super.key});

  @override
  State<CampusEatsApp> createState() => _CampusEatsAppState();
}

class _CampusEatsAppState extends State<CampusEatsApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
      ],
      child: MaterialApp.router,
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
      ],
      child: MaterialApp.router(
        title: 'CampusEats',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: createRouter(),
      ),
    );
  }
}
