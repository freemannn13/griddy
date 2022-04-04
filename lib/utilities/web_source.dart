import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WebSource {
  Document? _document;
  String baseUrl;
  final _client = http.Client();
  Map<String, String> headers = {};

  WebSource({required this.baseUrl});

  /// Loads the webpage into response object.
  Future<bool> loadWebPage(String route, {bool resetCookie = false}) async {
    if (baseUrl != '') {
      try {
        if (headers.isNotEmpty && resetCookie) {
          headers = {};
        }
        var _response =
            await _client.get(Uri.parse(baseUrl + route), headers: headers);
        if (headers.isEmpty) {
          _updateCookie(_response);
        }
        if (_response.statusCode == 200) {
          _document = parse(_response.body);
        } else {
          throw ErrorDescription(
              'Request to ${baseUrl + route} failed with status: ${_response.statusCode}');
        }
      } catch (e) {
        throw Exception(e.toString());
      }
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> getElement(String address, List<String> attribs) {
    if (_document == null) {
      throw Exception('getElement cannot be called before loadWebPage');
    }
    var elements = _document!.querySelectorAll(address);
    // ignore: omit_local_variable_types
    List<Map<String, dynamic>> elementData = [];

    for (var element in elements) {
      var attribData = <String, dynamic>{};
      for (var attrib in attribs) {
        attribData[attrib] = element.attributes[attrib];
      }
      elementData.add({
        'title': element.text,
        'attributes': attribData,
      });
    }
    return elementData;
  }

  void _updateCookie(http.Response response) async {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      String cookieId = rawCookie.split(';').firstWhere(
          (e) => e.contains(RegExp(
                'id=',
                caseSensitive: false,
              )),
          orElse: () => '');
      if (cookieId.contains(',')) {}
      headers['cookie'] =
          cookieId.contains(',') ? cookieId.split(',').last : cookieId;
    }
  }

  /// Close http client.
  void close() {
    _client.close();
  }
}
