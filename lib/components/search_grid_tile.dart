import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class SearchGridTile extends StatefulWidget {
  const SearchGridTile(
      {Key? key,
      required this.image,
      required this.link,
      required this.title,
      required this.description,
      required this.onTap})
      : super(key: key);

  final String image;
  final String link;
  final String title;
  final String description;
  final Function onTap;

  @override
  State<SearchGridTile> createState() => _SearchGridTileState();
}

class _SearchGridTileState extends State<SearchGridTile> {
  bool _showAddIcon = false;
  bool _showClick = false;
  bool _showAddBadge = false;
  bool _alreadyAdded = false;

  void _delayWidget() async {
    Map map = Provider.of<AppData>(context, listen: false)
        .templateList
        .firstWhere((element) => element['link'] == widget.link,
            orElse: () => {});
    if (_showClick) {
      if (mounted) {
        setState(() {
          _showAddBadge = true;
          _alreadyAdded = map.isNotEmpty ? true : false;
        });
        await Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _showAddBadge = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _showAddIcon = true),
      onExit: (event) => setState(() => _showAddIcon = false),
      opaque: false,
      child: Tooltip(
        message: widget.description,
        child: Listener(
          onPointerDown: (event) {
            setState(() {
              _showClick = true;
            });
            _delayWidget();
          },
          onPointerUp: (event) {
            setState(() {
              _showClick = false;
            });
            widget.onTap(
                widget.image, widget.link, widget.title, widget.description);
          },
          child: Stack(
            children: [
              Column(
                children: [
                  widget.image.contains('http')
                      ? SizedBox(
                          width: 160.0,
                          height: 212.0,
                          child: FadeInImage(
                            image: NetworkImage(
                              widget.image,
                            ),
                            placeholder: const AssetImage(
                              'images/image_placeholder.png',
                            ),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'images/image_placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 160.0,
                          height: 212.0,
                          color: const Color(0xFFBBBBBB),
                        ),
                  Container(
                    height: 50.0,
                    width: 160.0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    color:
                        _showAddIcon ? Colors.blue.lightest : Colors.grey[30],
                    child: Center(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _showAddIcon ? Colors.white : Colors.grey[120]),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                  left: 50.0,
                  top: 76.0,
                  child: AnimatedOpacity(
                    opacity: _showAddIcon ? 1 : 0,
                    duration: const Duration(milliseconds: 100),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: Icon(
                        FluentIcons.add,
                        color: Colors.blue,
                      ),
                      radius: 30.0,
                    ),
                  )),
              if (_showClick)
                Positioned(
                    child: Container(
                  width: 160.0,
                  height: 262.0,
                  color: Colors.white.withOpacity(0.5),
                )),
              if (_showAddBadge)
                Positioned(
                    top: 81.0,
                    left: 40.0,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(7.0),
                      width: 80.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: const [BoxShadow(blurRadius: 10.0)]),
                      child: Text(
                        _alreadyAdded ? 'Already added' : 'Added',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, height: 1.2),
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
