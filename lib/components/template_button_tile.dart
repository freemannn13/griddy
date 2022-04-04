import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class TemplateButtonTile extends StatefulWidget {
  const TemplateButtonTile({
    Key? key,
    required this.image,
    required this.link,
    required this.title,
    required this.description,
    required this.width,
    required this.height,
    required this.size,
    required this.onDelete,
  }) : super(key: key);

  final String image;
  final String link;
  final String title;
  final String description;
  final String width;
  final String height;
  final String size;
  final Function onDelete;

  @override
  State<TemplateButtonTile> createState() => _TemplateButtonTileState();
}

class _TemplateButtonTileState extends State<TemplateButtonTile> {
  bool? _value = false;

  void _check(List<Map<String, String>> list) {
    bool selected = false;
    for (var e in list) {
      if (e['link'] == widget.link) {
        selected = true;
        break;
      }
    }
    if (mounted) {
      setState(() {
        _value = selected ? true : false;
      });
    }
  }

  void _onTap() {
    if (Provider.of<AppData>(context, listen: false).displaySize.isNotEmpty) {
      Provider.of<AppData>(context, listen: false).updateSelectedTemplateList({
        'image': widget.image,
        'link': widget.link,
        'title': widget.title,
        'description': widget.description,
        'width': widget.width,
        'height': widget.height,
        'size': widget.size,
      });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(milliseconds: 2000),
                () => Navigator.pop(context));
            return ContentDialog(
              content: Column(
                children: [
                  Icon(
                    FluentIcons.alert_settings,
                    color: Colors.red.light,
                    size: 40.0,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Text(
                    'There are no display settings.',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0),
                  ),
                ],
              ),
            );
          });
    }
  }

  void _onDelete() {
    widget.onDelete({
      'image': widget.image,
      'link': widget.link,
      'title': widget.title,
      'description': widget.description,
      'width': widget.width,
      'height': widget.height,
      'size': widget.size,
    });
  }

  @override
  Widget build(BuildContext context) {
    _check(Provider.of<AppData>(context).selectedTemplateList);
    return Tooltip(
      message: widget.description,
      child: Stack(
        children: [
          OutlinedButton(
            style: ButtonStyle(
              shape: ButtonState.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              border: ButtonState.all(BorderSide(color: Colors.blue)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              height: 50.0,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: _onTap,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(10.0, 0.0),
              child: Tooltip(
                message: 'Add to view',
                child: Checkbox(
                  checked: _value,
                  onChanged: (value) => _onTap(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(-10.0, 0.0),
              child: Tooltip(
                message: 'Delete',
                child: IconButton(
                  onPressed: _onDelete,
                  icon: Icon(
                    FluentIcons.chrome_close,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
