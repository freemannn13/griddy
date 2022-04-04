import 'package:fluent_ui/fluent_ui.dart';
import 'package:griddy/utilities/safe_zone.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class DragBox extends StatefulWidget {
  const DragBox({
    Key? key,
    required this.initPos,
    required this.label,
    this.width = 100.0,
    this.height = 100.0,
    this.rotated = false,
  }) : super(key: key);

  final Offset initPos;
  final String label;
  final double width;
  final double height;
  final bool rotated;

  @override
  State<DragBox> createState() => _DragBoxState();
}

class _DragBoxState extends State<DragBox> {
  Offset _position = const Offset(0.0, 0.0);
  double _boxWidth = 100.0;
  double _boxHeight = 100.0;
  final Color _defaultColor = Colors.grey;
  bool _onPointerDown = false;
  final SafeZone _safeZone = SafeZone();
  List<Size> _offsetList = [];
  Offset? _cursorPosition;
  bool _switchCursor = false;
  bool _isRotated = false;
  int _rotate = 0;

  Widget _box({Color? boxColor}) => RotatedBox(
        quarterTurns: _rotate,
        child: Container(
          width: _boxWidth,
          height: _boxHeight,
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            border: Border.all(color: _defaultColor),
            borderRadius: BorderRadius.circular(5.0),
            color: boxColor ?? Colors.grey[10],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(_boxWidth, _boxHeight),
                  painter: MyPainter(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: _rotate == 3 ? 1 : 0,
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _defaultColor,
                      // decoration: TextDecoration.none,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );

  void _update(Map<String, Map<Offset, List<dynamic>>> map) {
    Offset offset = map[widget.label]!.keys.first;
    double width = map[widget.label]!.values.first[0];
    double height = map[widget.label]!.values.first[1];
    bool rotated = map[widget.label]!.values.first[2];
    _position = offset;
    _boxWidth = width;
    _boxHeight = height;
    _rotate = rotated ? 3 : 0;
  }

  void _onTop() {
    Map<String, Map<Offset, List<dynamic>>> boxes =
        Provider.of<AppData>(context, listen: false).templatesBoxes;
    Map<String, Map<Offset, List<dynamic>>> tempMap = {};
    Map<String, Map<Offset, List<dynamic>>> element = {};
    if (boxes.keys.last != widget.label) {
      for (var e in boxes.entries) {
        if (e.key == widget.label) {
          element = {e.key: e.value};
        } else {
          tempMap[e.key] = e.value;
        }
      }
      tempMap[element.keys.first] = element.values.first;
    }
    if (tempMap.isNotEmpty) {
      Provider.of<AppData>(context, listen: false)
          .updateTemplatesBoxes(tempMap, updateAll: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _position = widget.initPos;
    _boxWidth = widget.width;
    _boxHeight = widget.height;
    _isRotated = widget.rotated;
    _rotate = _isRotated ? 3 : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_onPointerDown) {
      _update(Provider.of<AppData>(context).templatesBoxes);
    }
    return Positioned(
        left: _position.dx,
        top: _position.dy,
        child: MouseRegion(
          cursor: SystemMouseCursors.none,
          opaque: true,
          onEnter: (event) => _onTop(),
          onHover: (event) {
            setState(() {
              _cursorPosition = event.localPosition;
              if ((_isRotated ? _cursorPosition!.dy : _cursorPosition!.dx) <
                      _boxWidth * 0.1 ||
                  (_isRotated ? _cursorPosition!.dy : _cursorPosition!.dx) >
                      _boxWidth * 0.9 ||
                  (_isRotated ? _cursorPosition!.dx : _cursorPosition!.dy) <
                      _boxHeight * 0.1 ||
                  (_isRotated ? _cursorPosition!.dx : _cursorPosition!.dy) >
                      _boxHeight * 0.9) {
                _switchCursor = true;
              } else {
                _switchCursor = false;
              }
            });
          },
          onExit: (event) => setState(() => _cursorPosition = null),
          child: Listener(
            onPointerDown: (event) => setState(() {
              if (_switchCursor) {
                _isRotated = _isRotated ? false : true;
                _rotate = _rotate == 0 ? 3 : 0;
              }
              _onPointerDown = true;
            }),
            onPointerMove: (event) => setState(() {
              if (_offsetList.isEmpty) {
                _offsetList.add(Size(event.position.dx - _position.dx,
                    event.position.dy - _position.dy));
              }
              _position = _safeZone.check(
                  context,
                  Offset(event.position.dx - _offsetList.first.width,
                      event.position.dy - _offsetList.first.height),
                  _isRotated ? _boxHeight : _boxWidth,
                  _isRotated ? _boxWidth : _boxHeight);
            }),
            onPointerUp: (event) {
              Provider.of<AppData>(context, listen: false)
                  .updateTemplatesBoxes({
                widget.label: {
                  _position: [_boxWidth, _boxHeight, _isRotated]
                }
              });
              setState(() {
                _offsetList = [];
                _onPointerDown = false;
              });
            },
            child: Stack(
              children: [
                Opacity(
                  opacity: _onPointerDown ? 0.5 : 1.0,
                  child: _box(
                      boxColor: _onPointerDown || _cursorPosition != null
                          ? Colors.white
                          : null),
                ),
                if (_cursorPosition != null)
                  AnimatedPositioned(
                    duration: const Duration(),
                    left: _cursorPosition?.dx,
                    top: _cursorPosition?.dy,
                    child: Icon(_switchCursor
                        ? FluentIcons.rotate90_clockwise
                        : FluentIcons.hands_free),
                  ),
              ],
            ),
          ),
        ));
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset p1 = const Offset(0, 0);
    Offset p2 = Offset(size.width / 3, size.height / 3);
    Offset p3 = Offset(size.width * 2 / 3, size.height * 2 / 3);
    Offset p4 = Offset(size.width, size.height);
    Offset p5 = Offset(0, size.height);
    Offset p6 = Offset(size.width / 3, size.height * 2 / 3);
    Offset p7 = Offset(size.width * 2 / 3, size.height / 3);
    Offset p8 = Offset(size.width, 0);
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.5;
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p3, p4, paint);
    canvas.drawLine(p5, p6, paint);
    canvas.drawLine(p7, p8, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
