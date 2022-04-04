import 'package:flutter/foundation.dart';
import 'package:griddy/utilities/web_source.dart';

class TemplateInfo {
  final webSource = WebSource(baseUrl: 'https://www.gsmarena.com');

  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _links = [];
  List<Map<String, dynamic>> _titles = [];
  List<Map<String, dynamic>> _descriptions = [];
  List<Map<String, dynamic>> _dimension = [];

  Future<List<Map<String, String>>> fetch({
    bool search = false,
    String searchValue = '',
    String page = '',
  }) async {
    List<Map<String, String>> list = [];
    String pageValue = '';
    try {
      if (search) {
        pageValue = '/results.php3?sQuickSearch=yes&sName=' + searchValue;
      } else {
        pageValue = '/' + page;
      }
      if (await webSource.loadWebPage(pageValue)) {
        if (search) {
          _images = webSource.getElement(
              'div.section-body > div.makers > ul > li > a > img', ['src']);
          _links = webSource.getElement(
              'div.section-body > div.makers > ul > li > a', ['href']);
          _titles = webSource
              .getElement('div.section-body > div.makers > ul > li > a', []);
          _descriptions = webSource.getElement(
              'div.section-body > div.makers > ul > li > a > img', ['title']);
        } else {
          _dimension = webSource.getElement(
              'div.main.main-review.right.l-box.col > div > table > tbody > tr',
              []);
        }
      }

      if (search) {
        for (int i = 0; i < _titles.length; i++) {
          list.add({
            'image': _images[i]['attributes']['src'],
            'link': _links[i]['attributes']['href'],
            'title': _titles[i]['title'],
            'description': _descriptions[i]['attributes']['title'],
          });
        }
      } else {
        String width = '';
        String height = '';
        String size = '';
        for (var e in _dimension) {
          if (e['title'].contains('Size')) {
            size = e['title'].trim().split('\n').last.split(' ').first;
          }
          if (e['title'].contains('Resolution')) {
            List<String> tmp = e['title'].trim().split('\n').last.split(' ');
            width = tmp[0];
            height = tmp[2];
          }
        }
        list.add({
          'width': width,
          'height': height,
          'size': size,
        });
      }
    } catch (e) {
      debugPrint('Error from GsmArena: $e');
    }
    return list;
  }
}
