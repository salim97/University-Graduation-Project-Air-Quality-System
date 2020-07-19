import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'ui_helper.dart';

class CustomWidget extends StatefulWidget {
  final double currentSearchPercent;
  final Map<String, String> data;
  final Function(String) onCurrentSearchChanged;
  const CustomWidget({Key key, this.currentSearchPercent, this.data, this.onCurrentSearchChanged}) : super(key: key);

  @override
  _CustomWidgetState createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<DataRow> dataArray = [];
    widget.data.forEach((key, value) => dataArray.add(
          DataRow(cells: [
            DataCell(
              Text(key),
            ),
            DataCell(
              Text(value),
            ),
          ]),
        ));
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text('ID'),
                          ),
                          DataColumn(
                            label: Text('FIRST NAME'),
                          ),
                        ],
                        rows: dataArray,
                      ),
                    
                    ),
                  )),
            ))
        : const Padding(
            padding: const EdgeInsets.all(0),
          );
  }


}
