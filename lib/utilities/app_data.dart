import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppData extends ChangeNotifier {
  final LazyBox _selectedTemplates = Hive.lazyBox('selectedTemplates');
  final LazyBox _templates = Hive.lazyBox('templates');
  final LazyBox _positionBox = Hive.lazyBox('positionBox');
  final LazyBox _displaySettings = Hive.lazyBox('displaySettings');

  String lastSearch = '';

  void updateLastSearch(String value) {
    lastSearch = value;
    notifyListeners();
  }

  // templates boxes map structure { label : { (0,0) : [double width, double height, bool rotated ] }}
  Map<String, Map<Offset, List<dynamic>>> templatesBoxes = {};

  void updateTemplatesBoxes(Map<String, Map<Offset, List<dynamic>>> value,
      {bool updateAll = false}) {
    if (updateAll) {
      templatesBoxes = value;
    } else {
      templatesBoxes[value.keys.first] = value.values.first;
      _positionBox.put(value.keys.first, {
        [value.values.first.keys.first.dx, value.values.first.keys.first.dy]:
            value.values.first.values.first
      });
    }
    notifyListeners();
  }

  Map<String, double> displaySize = {};

  // display width, height in inches
  double displayWidth = 0.0;
  double displayHeight = 0.0;

  // display pixel per inch
  double displayPPI = 0.0;

  void updateDisplaySize(Map<String, double> value, {bool save = false}) async {
    if (save) {
      _displaySettings.put('settings', {
        'displayResolutionWidth': value['width'],
        'displayResolutionHeight': value['height'],
        'displayDiagonal': value['diagonal'],
      });
    }
    displaySize = value;
    double width = value['width']!;
    double height = value['height']!;
    double diagonal = value['diagonal']!;
    double aspectRatio = width / height;
    displayHeight = diagonal / sqrt(1 + pow(aspectRatio, 2));
    displayWidth = aspectRatio * displayHeight;
    displayPPI = width / displayWidth;
    notifyListeners();
  }

  List<Map<String, String>> templateList = [];

  void updateTemplateList(Map<String, String> value) {
    if (templateList.isNotEmpty) {
      bool contained = false;
      for (var e in templateList) {
        if (e['link'] == value['link']) {
          contained = true;
          break;
        }
      }
      if (!contained) {
        templateList.add(value);
        _templates.put(value['link'], value);
      }
    } else {
      templateList.add(value);
      _templates.put(value['link'], value);
    }

    notifyListeners();
  }

  List<dynamic> calculateTemplateSize(
      String width, String height, String diagonal) {
    List<dynamic> result = [0.0, 0.0, false];
    double tempWidth = double.tryParse(width) ?? 100.0;
    double tempHeight = double.tryParse(height) ?? 100.0;
    double tempDiagonal = double.tryParse(diagonal) ?? 5.0;
    double aspectRatio =
        max(tempWidth, tempHeight) / min(tempWidth, tempHeight);
    double tempDisplayHeight = 0.0;
    double tempDisplayWidth = 0.0;
    if (tempHeight > tempWidth) {
      tempDisplayWidth = tempDiagonal / sqrt(1 + pow(aspectRatio, 2));
      tempDisplayHeight = aspectRatio * tempDisplayWidth;
    } else {
      tempDisplayHeight = tempDiagonal / sqrt(1 + pow(aspectRatio, 2));
      tempDisplayWidth = aspectRatio * tempDisplayHeight;
    }
    result = [
      tempDisplayWidth * displayPPI,
      tempDisplayHeight * displayPPI,
      false
    ];
    return result;
  }

  List<Map<String, String>> selectedTemplateList = [];

  void updateSelectedTemplateList(Map<String, String> value) async {
    String boxTitle = value['title']! +
        '\n' +
        value['width']! +
        ' x ' +
        value['height']! +
        ' pixels\n' +
        value['size']! +
        ' inches';
    List<dynamic> list = calculateTemplateSize(
        value['width']!, value['height']!, value['size']!);
    if (selectedTemplateList.isNotEmpty) {
      bool selected = false;
      Map<String, String> tmp = {};
      for (var e in selectedTemplateList) {
        if (e['link'] == value['link']) {
          selected = true;
          tmp = e;
          break;
        }
      }
      if (selected) {
        templatesBoxes.remove(boxTitle);
        _positionBox.delete(boxTitle);
        _selectedTemplates.delete(value['link']);
        selectedTemplateList.remove(tmp);
      } else {
        templatesBoxes[boxTitle] = {const Offset(0, 0): list};
        _positionBox.put(boxTitle, {
          [0, 0]: list
        });
        selectedTemplateList.add(value);
        _selectedTemplates.put(value['link'], value);
      }
    } else {
      templatesBoxes[boxTitle] = {const Offset(0, 0): list};
      _positionBox.put(boxTitle, {
        [0, 0]: list
      });
      selectedTemplateList.add(value);
      _selectedTemplates.put(value['link'], value);
    }
    notifyListeners();
  }

  void updateTemplatesFromDisk() async {
    if (_positionBox.isNotEmpty) {
      for (int i = 0; i < _positionBox.length; i++) {
        var key = await _positionBox.keyAt(i);
        var value = await _positionBox.getAt(i);
        templatesBoxes[key as String] = {
          Offset(value.keys.first.first.toDouble(),
              value.keys.first.last.toDouble()): value.values.first
        };
      }
    }
    if (_templates.isNotEmpty) {
      for (int i = 0; i < _templates.length; i++) {
        var value = await _templates.getAt(i);
        templateList.add(Map<String, String>.from(value));
      }
    }
    if (_selectedTemplates.isNotEmpty) {
      for (int i = 0; i < _selectedTemplates.length; i++) {
        var value = await _selectedTemplates.getAt(i);
        selectedTemplateList.add(Map<String, String>.from(value));
      }
    }
    notifyListeners();
  }

  void deleteTemplate(Map<String, String> value) {
    String boxTitle = value['title']! +
        '\n' +
        value['width']! +
        ' x ' +
        value['height']! +
        ' pixels\n' +
        value['size']! +
        ' inches';
    if (selectedTemplateList.isNotEmpty) {
      bool selected = false;
      Map<String, String> tmp = {};
      for (var e in selectedTemplateList) {
        if (e['link'] == value['link']) {
          selected = true;
          tmp = e;
          break;
        }
      }
      if (selected) {
        templatesBoxes.remove(boxTitle);
        _positionBox.delete(boxTitle);
        _selectedTemplates.delete(value['link']);
        selectedTemplateList.remove(tmp);
        _templates.delete(value['link']);
        templateList.removeWhere((element) => element['link'] == value['link']);
      } else {
        _templates.delete(value['link']);
        templateList.removeWhere((element) => element['link'] == value['link']);
      }
    } else {
      _templates.delete(value['link']);
      templateList.removeWhere((element) => element['link'] == value['link']);
    }
    notifyListeners();
  }
}
