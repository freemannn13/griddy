import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:griddy/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(Directory.current.path + '/config');
  await Hive.openLazyBox('selectedTemplates');
  await Hive.openLazyBox('templates');
  await Hive.openLazyBox('positionBox');
  await Hive.openLazyBox('displaySettings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: Consumer<AppData>(
        builder: (context, provider, child) => const FluentApp(
          title: 'Griddy',
          home: HomeScreen(),
        ),
      ),
    );
  }
}
