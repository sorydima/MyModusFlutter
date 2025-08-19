import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'theme.dart';
import 'l10n/l10n.dart';
import 'providers/app_provider.dart';

class MyModusApp extends StatelessWidget {
  MyModusApp({Key? key}) : super(key: key);

  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        // Другие провайдеры будут доступны через AppProvider
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp.router(
            title: 'MyModus',
            theme: appProvider.currentTheme == 'light' ? appTheme : appTheme, // TODO: добавить темную тему
            routerConfig: _router,
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: Locale(appProvider.currentLanguage),
            builder: (context, child) {
              // Показываем индикатор загрузки, если приложение инициализируется
              if (appProvider.isAnythingLoading && !appProvider.isInitialized) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Инициализация MyModus...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              // Показываем ошибки, если они есть
              if (appProvider.hasErrors) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Произошла ошибка',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Попробуйте перезапустить приложение',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                appProvider.clearAllErrors();
                                appProvider.initialize();
                              },
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              return child!;
            },
          );
        },
      ),
    );
  }
}
