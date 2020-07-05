
import 'package:air_quality_system/ui/screens/forecast/forecast_view.dart';
import 'package:flutter/material.dart';
import 'ui_helper.dart';

class ExploreContentWidget extends StatelessWidget {
  final double currentExplorePercent;
  final placeName = const ["Authentic\nrestaurant", "Famous\nmonuments", "Weekend\ngetaways"];
  const ExploreContentWidget({Key key, this.currentExplorePercent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentExplorePercent != 0) {
      return Positioned(
        top: realH(standardHeight + (162 - standardHeight) * currentExplorePercent),
        width: screenWidth,
        child: Container(
          height: screenHeight,
          child: Expanded(child: new ForecastView()),
        ),
      );
    } else {
      return const Padding(
        padding: const EdgeInsets.all(0),
      );
    }
  }


}
