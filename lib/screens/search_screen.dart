import 'package:fluent_ui/fluent_ui.dart';
import 'package:griddy/components/search_grid_tile.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';
import 'package:griddy/utilities/template_info.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _key = GlobalKey();
  double _resultsContainerHeight = 100.0;
  Size _size = const Size(0, 0);
  bool _showLoader = false;
  bool _showNoResults = false;
  List<SearchGridTile> _widgetList = [];
  final TemplateInfo _info = TemplateInfo();
  List<Map<String, String>> _infoList = [];

  void _onSubmit(String value) async {
    if (value.isNotEmpty) {
      if (mounted) {
        _widgetList = [];
        _infoList = [];
        setState(() {
          _showLoader = true;
        });
      }
      Provider.of<AppData>(context, listen: false).updateLastSearch(value);
      _infoList = await _info.fetch(search: true, searchValue: value);
      for (var element in _infoList) {
        _widgetList.add(SearchGridTile(
            image: element['image']!,
            link: element['link']!,
            title: element['title']!,
            description: element['description']!,
            onTap: _onTap));
      }
      if (mounted) {
        setState(() {
          _showLoader = false;
          _showNoResults = _widgetList.isEmpty ? true : false;
        });
      }
    }
  }

  void _onTap(
      String image, String link, String title, String description) async {
    Map<String, String> map = {};
    List<Map<String, dynamic>> result = await _info.fetch(page: link);
    if (result.isNotEmpty) {
      map['image'] = image;
      map['link'] = link;
      map['title'] = title;
      map['description'] = description;
      map['width'] = result.first['width']!;
      map['height'] = result.first['height']!;
      map['size'] = result.first['size']!;
      Provider.of<AppData>(context, listen: false).updateTemplateList(map);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
      _size = box.size;
      setState(() {
        _resultsContainerHeight =
            MediaQuery.of(context).size.height - _size.height - 24;
      });
      String lastSearch =
          Provider.of<AppData>(context, listen: false).lastSearch;
      if (lastSearch.isNotEmpty) {
        _controller.text = lastSearch;
        _onSubmit(lastSearch);
      }
    });
  }

  @override
  void dispose() {
    _info.webSource.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _resultsContainerHeight =
        MediaQuery.of(context).size.height - _size.height - 24;
    return ScaffoldPage(
      content: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15),
        child: Column(
          children: [
            Column(
              key: _key,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Templates',
                  style: TextStyle(fontSize: 20.0),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextBox(
                  controller: _controller,
                  placeholder: 'Search',
                  prefix: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(FluentIcons.search),
                  ),
                  onSubmitted: _onSubmit,
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
            Container(
              height: _resultsContainerHeight,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[50]),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0))),
              child: _widgetList.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        mainAxisExtent: 262.0,
                      ),
                      itemCount: _widgetList.length,
                      itemBuilder: (BuildContext context, index) {
                        return _widgetList[index];
                      })
                  : _showLoader
                      ? const Center(child: ProgressRing())
                      : _showNoResults
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    FluentIcons.emoji_disappointed,
                                    size: 25.0,
                                  ),
                                  Text(
                                    'No Results',
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey[40], width: 1.7),
                                    borderRadius: BorderRadius.circular(100)),
                                child: Icon(
                                  FluentIcons.search,
                                  color: Colors.grey[40],
                                  size: 25.0,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
