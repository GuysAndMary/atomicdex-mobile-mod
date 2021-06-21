import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/constructor/coins_list_depths.dart';
import 'package:provider/provider.dart';
import 'package:rational/rational.dart';

import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';

class CoinsList extends StatefulWidget {
  const CoinsList({this.type});

  final CoinType type;

  @override
  _CoinsListState createState() => _CoinsListState();
}

class _CoinsListState extends State<CoinsList> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    final Rational _counterAmount = widget.type == CoinType.base
        ? _constrProvider.buyAmount
        : _constrProvider.sellAmount;

    if (_counterAmount == null) {
      return CoinsListDepths(type: widget.type);
    } else {
      return SizedBox();
    }
  }
}
