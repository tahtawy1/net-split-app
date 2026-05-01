import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'feature/calculation/cubit/calculation_cubit.dart';
import 'feature/calculation/view/calculation_view.dart';
import 'feature/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 780),
    minimumSize: Size(900, 600),
    center: true,
    title: 'NetSplit',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final storageService = StorageService();
  await storageService.init();

  runApp(NetSplitApp(storageService: storageService));
}

class NetSplitApp extends StatefulWidget {
  final StorageService storageService;

  const NetSplitApp({super.key, required this.storageService});

  @override
  State<NetSplitApp> createState() => _NetSplitAppState();
}

class _NetSplitAppState extends State<NetSplitApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CalculationCubit(widget.storageService)),
      ],
      child: MaterialApp(
        title: 'NetSplit',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: SplashScreen(
          nextScreen: CalculationView(
            isDark: _themeMode == ThemeMode.dark,
            onToggleTheme: _toggleTheme,
          ),
        ),
      ),
    );
  }
}
