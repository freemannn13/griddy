import 'package:fluent_ui/fluent_ui.dart';

class SafeZone {
  Offset check(
      BuildContext context, Offset offset, double boxWidth, double boxHeight) {
    Offset result = offset;
    if (offset.dx < 0) {
      result = Offset(0, offset.dy);
    } else if (offset.dx >
        MediaQuery.of(context).size.width - boxWidth - 50.0) {
      result = Offset(
          MediaQuery.of(context).size.width - boxWidth - 50.0, offset.dy);
    } else if (offset.dy < 0) {
      result = Offset(offset.dx, 0);
    } else if (offset.dy > MediaQuery.of(context).size.height - boxHeight) {
      result =
          Offset(offset.dx, MediaQuery.of(context).size.height - boxHeight);
    }
    if (offset.dx < 0 && offset.dy < 0) {
      result = const Offset(0, 0);
    } else if (offset.dx < 0 &&
        offset.dy > MediaQuery.of(context).size.height - boxHeight) {
      result = Offset(0, MediaQuery.of(context).size.height - boxHeight);
    } else if (offset.dx >
            MediaQuery.of(context).size.width - boxWidth - 50.0 &&
        offset.dy < 0) {
      result = Offset(MediaQuery.of(context).size.width - boxWidth - 50.0, 0);
    } else if (offset.dx >
            MediaQuery.of(context).size.width - boxWidth - 50.0 &&
        offset.dy > MediaQuery.of(context).size.height - boxHeight) {
      result = Offset(MediaQuery.of(context).size.width - boxWidth - 50.0,
          MediaQuery.of(context).size.height - boxHeight);
    }
    return result;
  }
}
