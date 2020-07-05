import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'ui_helper.dart';

class SearchMenuWidget extends StatefulWidget {
  final double currentSearchPercent;
  final Map<String, IconData> gas;
  final Function(String) onCurrentSearchChanged;
  const SearchMenuWidget({Key key, this.currentSearchPercent, this.gas, this.onCurrentSearchChanged}) : super(key: key);

  @override
  _SearchMenuWidgetState createState() => _SearchMenuWidgetState();
}

class _SearchMenuWidgetState extends State<SearchMenuWidget> {


  String currentSelectedItem;

  @override
  void initState() {
    super.initState();
    currentSelectedItem = widget.gas.keys.first;
  }

  onMenuItemClicked(String item) {
    setState(() {
      currentSelectedItem = item;
    });
    // print(item);
    widget.onCurrentSearchChanged(item);
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentSearchPercent != 0
        ? Positioned(
            bottom: realH(58 + (144 - 58) * widget.currentSearchPercent),
            left: realW((standardWidth - 320) / 2),
            width: realW(320),
            height: realH(360),
            child: Opacity(
              opacity: widget.currentSearchPercent,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: realW(20.0)),
                  child: ListView.builder(
                      itemCount: widget.gas.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildSearchMenuItem(widget.gas.values.elementAt(index), widget.gas.keys.elementAt(index));
                      })),
            ))
        : const Padding(
            padding: const EdgeInsets.all(0),
          );
  }

  _buildSearchMenuItem(IconData icon, String text) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // life saver <3
      onTap: () => onMenuItemClicked(text),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: realW(130),
          height: realH(60),
          padding: EdgeInsets.only(left: realW(17)),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: realW(30),
                color: Colors.blue,
              ),
              Padding(
                padding: EdgeInsets.only(left: realW(12)),
              ),
              Text(
                text,
                style: TextStyle(color: Colors.black, fontSize: realW(18)),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: currentSelectedItem == text ? Color(0xFF379BF2).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(realW(30))),
          ),
        ),
      ),
    );
  }
}
