import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';
import 'template_button_tile.dart';

class TemplateMenu {
  TemplateMenu(this.context);

  final BuildContext context;

  List<TemplateButtonTile> _widgetList = [];
  late StateSetter _setState;

  List<TemplateButtonTile> _updateList(List<Map<String, String>> list) {
    List<TemplateButtonTile> result = [];
    if (list.isNotEmpty) {
      for (var element in list) {
        result.add(TemplateButtonTile(
          image: element['image']!,
          link: element['link']!,
          title: element['title']!,
          description: element['description']!,
          width: element['width']!,
          height: element['height']!,
          size: element['size']!,
          onDelete: _onDelete,
        ));
      }
    }
    return result;
  }

  void _onDelete(Map<String, String> value) {
    Provider.of<AppData>(context, listen: false).deleteTemplate(value);
    _setState(() {
      _widgetList = _updateList(
          Provider.of<AppData>(context, listen: false).templateList);
    });
  }

  Future<void> showMenu() {
    _widgetList =
        _updateList(Provider.of<AppData>(context, listen: false).templateList);
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          _setState = setState;
          return ContentDialog(
            constraints: BoxConstraints(
                minWidth: 300,
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 300.0,
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: _widgetList.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400.0,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        mainAxisExtent: 50.0,
                      ),
                      itemCount: _widgetList.length,
                      itemBuilder: (BuildContext context, index) {
                        return _widgetList[index];
                      })
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            FluentIcons.cell_phone,
                            size: 25.0,
                          ),
                          Text(
                            'No Templates',
                            style: TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
            ),
            actions: [
              Button(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        },
      ),
    );
  }
}
