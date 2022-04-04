import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:griddy/screens/search_screen.dart';
import 'package:griddy/components/settings_menu.dart';
import 'package:griddy/components/template_menu.dart';
import 'package:griddy/screens/view_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LazyBox _displaySettings = Hive.lazyBox('displaySettings');
  int index = 0;

  void _getLoad() async {
    await DesktopWindow.setMinWindowSize(const Size(800, 600));
    var settings = await _displaySettings.get('settings');
    if (settings != null) {
      Provider.of<AppData>(context, listen: false).updateDisplaySize({
        'width': settings['displayResolutionWidth'],
        'height': settings['displayResolutionHeight'],
        'diagonal': settings['displayDiagonal'],
      });
    }
    Provider.of<AppData>(context, listen: false).updateTemplatesFromDisk();
  }

  @override
  void initState() {
    super.initState();
    _getLoad();
  }

  @override
  Widget build(BuildContext context) {
    int templateListCount = Provider.of<AppData>(context).templateList.length;
    int viewListCount = Provider.of<AppData>(context).templatesBoxes.length;
    return NavigationView(
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMinWidth: 250,
          openMaxWidth: 320,
        ),
        displayMode: PaneDisplayMode.compact,
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset(
              'images/logo.png',
              height: 30.0,
            ),
          ),
        ),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.screen),
            title: const Text('View'),
            infoBadge: viewListCount != 0
                ? InfoBadge(source: Text(viewListCount.toString()))
                : null,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.search),
            title: const Text('Search Templates'),
          ),
          PaneItemSeparator(),
          PaneItemAction(
            icon: const Icon(FluentIcons.cell_phone),
            title: const Text('Mobile Templates'),
            infoBadge: templateListCount != 0
                ? InfoBadge(source: Text(templateListCount.toString()))
                : null,
            onTap: () async => await TemplateMenu(context).showMenu(),
          ),
          PaneItemSeparator(),
          PaneItemAction(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Display Settings'),
            onTap: () => SettingsMenu().showSettingsMenu(context),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: const [
          ViewScreen(),
          SearchScreen(),
        ],
      ),
    );
  }
}
