import 'package:air_quality_system/ui/styles/Res.dart';
import 'package:flutter/material.dart';

class DotPageIndicator extends StatelessWidget {
  final int currentPage;
  final int pagesCount;

  DotPageIndicator(this.currentPage, this.pagesCount);

  @override
  Widget build(BuildContext context) {
    var dots = <Widget>[];
    final dotEmpty = new Flexible(
        child: new Image(
          image: new AssetImage($Asset.dotEmpty),
          width: 15.0,
          height: 15.0,
          color: Colors.white,
        ));

    final dotFull = new Flexible(
        child: new Image(
          image: new AssetImage($Asset.dotFull),
          width: 15.0,
          height: 15.0,
          color: Colors.white,
        ));

    for (var i=0; i<pagesCount; i++) {
      if (i == currentPage)
        dots.add(dotFull);
      else
        dots.add(dotEmpty);
    }

    return new Container(
      // color: Colors.transparent,
      padding: new EdgeInsets.only(top: 8.0),
      alignment: FractionalOffset.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: dots,
      ),
    );
  }
}