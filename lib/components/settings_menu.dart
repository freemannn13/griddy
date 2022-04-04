import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:griddy/utilities/app_data.dart';

class SettingsMenu {
  void showSettingsMenu(BuildContext context) {
    String widthValue = '';
    String heightValue = '';
    String inchValue = '';
    TextEditingController controllerWidth = TextEditingController();
    TextEditingController controllerHeight = TextEditingController();
    TextEditingController controllerInches = TextEditingController();
    bool errorColorWidthText = false;
    bool errorColorHeightText = false;
    bool errorColorInchesText = false;
    AppData provider = Provider.of<AppData>(context, listen: false);
    if (provider.displaySize.isNotEmpty) {
      controllerWidth.text = provider.displaySize['width']!.toStringAsFixed(0);
      widthValue = provider.displaySize['width'].toString();
      controllerHeight.text =
          provider.displaySize['height']!.toStringAsFixed(0);
      heightValue = provider.displaySize['height'].toString();
      controllerInches.text = provider.displaySize['diagonal'].toString();
      inchValue = provider.displaySize['diagonal'].toString();
    }
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return ContentDialog(
                title: const Text('Settings'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Display resolution:'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 30,
                          child: TextBox(
                            placeholder: 'width',
                            controller: controllerWidth,
                            decoration: errorColorWidthText
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.red))
                                : null,
                            onChanged: (value) => widthValue = value,
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Text(
                                'px',
                                style: TextStyle(color: Colors.grey[100]),
                              ),
                            ),
                          ),
                        ),
                        const Text('x'),
                        SizedBox(
                          width: 150,
                          height: 30,
                          child: TextBox(
                            placeholder: 'height',
                            controller: controllerHeight,
                            decoration: errorColorHeightText
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.red))
                                : null,
                            onChanged: (value) => heightValue = value,
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Text(
                                'px',
                                style: TextStyle(color: Colors.grey[100]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text('Display size:'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: TextBox(
                        placeholder: 'inches',
                        controller: controllerInches,
                        decoration: errorColorInchesText
                            ? BoxDecoration(
                                border: Border.all(color: Colors.red))
                            : null,
                        onChanged: (value) => setState(() => inchValue = value),
                        suffix: inchValue.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  'inch',
                                  style: TextStyle(color: Colors.grey[100]),
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (errorColorWidthText ||
                        errorColorHeightText ||
                        errorColorInchesText)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10.0),
                          Text(
                            'Wrong value(s)',
                            style: TextStyle(
                                color: Colors.red, fontStyle: FontStyle.italic),
                          ),
                        ],
                      )
                  ],
                ),
                actions: [
                  Button(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  Button(
                      child: const Text('Ok'),
                      onPressed: () {
                        if (widthValue.isNotEmpty &&
                            double.tryParse(widthValue) != null &&
                            heightValue.isNotEmpty &&
                            double.tryParse(heightValue) != null &&
                            inchValue.isNotEmpty &&
                            double.tryParse(inchValue) != null) {
                          Provider.of<AppData>(context, listen: false)
                              .updateDisplaySize({
                            'width': double.parse(widthValue),
                            'height': double.parse(heightValue),
                            'diagonal': double.parse(inchValue),
                          }, save: true);
                          Navigator.pop(context);
                        } else {
                          if (widthValue.isEmpty ||
                              double.tryParse(widthValue) == null) {
                            setState(() {
                              errorColorWidthText = true;
                            });
                          } else {
                            setState(() {
                              errorColorWidthText = false;
                            });
                          }
                          if (heightValue.isEmpty ||
                              double.tryParse(heightValue) == null) {
                            setState(() {
                              errorColorHeightText = true;
                            });
                          } else {
                            setState(() {
                              errorColorHeightText = false;
                            });
                          }
                          if (inchValue.isEmpty ||
                              double.tryParse(inchValue) == null) {
                            setState(() {
                              errorColorInchesText = true;
                            });
                          } else {
                            setState(() {
                              errorColorInchesText = false;
                            });
                          }
                        }
                      })
                ],
              );
            }));
  }
}
