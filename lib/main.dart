import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Data format tanggal bahasa Indonesia (nama hari pada forecast).
  await initializeDateFormatting('id_ID', null);
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service (lapisan data)
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<StorageService>(create: (_) => StorageService()),

        // ViewModel (state management dengan Provider)
        ChangeNotifierProvider<WeatherViewModel>(
          create: (context) => WeatherViewModel(
            context.read<WeatherService>(),
            context.read<StorageService>(),
          )..init(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          lazy: false,
          create: (context) => SearchViewModel(
            context.read<WeatherService>(),
            context.read<StorageService>(),
          )..loadSaved(),
        ),
      ],
      child: MaterialApp(
        title: 'Cuaca',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
