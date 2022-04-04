import 'package:fluent_ui/fluent_ui.dart';
import 'package:griddy/components/drag_box.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<Widget> _dragBoxList = [];

  void _generateList(Map<String, Map<Offset, List<dynamic>>> map) {
    _dragBoxList = [];
    if (map.isNotEmpty) {
      for (var element in map.entries) {
        _dragBoxList.add(DragBox(
          initPos: element.value.keys.first,
          label: element.key,
          width: element.value.values.first[0],
          height: element.value.values.first[1],
          rotated: element.value.values.first[2],
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _generateList(Provider.of<AppData>(context).templatesBoxes);
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: _dragBoxList.isNotEmpty
          ? Stack(
              children: _dragBoxList,
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    FluentIcons.cell_phone,
                    size: 25.0,
                  ),
                  Text(
                    'No Preview Templates',
                    style:
                        TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }
}
