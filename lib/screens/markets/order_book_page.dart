import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/order_book_chart.dart';
import 'package:komodo_dex/screens/markets/order_book_table.dart';
import 'package:komodo_dex/widgets/candles_icon.dart';
import 'package:komodo_dex/widgets/duration_select.dart';
import 'package:provider/provider.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage();

  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  OrderBookProvider _orderBookProvider;
  CexProvider _cexProvider;
  bool _hasBothCoins = false;
  bool _hasChartsData = false;
  String _pairStr;
  bool _showChart = false;
  String _chartDuration = '3600';
  List<String> _durationData;
  int listLength = 0;
  int listLimit = 25;
  int listLimitMin = 25;
  int listLimitStep = 5;

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);
    _cexProvider = Provider.of<CexProvider>(context);
    _hasBothCoins = _orderBookProvider.activePair?.sell != null &&
        _orderBookProvider.activePair?.buy != null;
    _pairStr = _hasBothCoins
        ? '${_orderBookProvider.activePair.sell.abbr}-${_orderBookProvider.activePair.buy.abbr}'
        : null;
    _hasChartsData = _hasBothCoins && _cexProvider.isChartAvailable(_pairStr);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
            ),
            child: _buildPairSelect(),
          ),
          if (_hasChartsData)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: _buildTabsButtons(),
            ),
          if (_showChart) _buildCandleChart(),
          if (!_showChart) _buildOrderBook(),
        ],
      ),
    );
  }

  Widget _buildPairSelect() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: CoinSelect(
                  key: const Key('coin-select-left'),
                  value: _orderBookProvider.activePair?.sell,
                  type: CoinType.base,
                  pairedCoin: _orderBookProvider.activePair?.buy,
                  autoOpen: _orderBookProvider.activePair?.sell == null &&
                      _orderBookProvider.activePair?.buy != null,
                  compact: MediaQuery.of(context).size.width < 360,
                  onChange: (Coin value) {
                    setState(() {
                      _showChart = false;
                    });
                    _orderBookProvider.activePair = CoinsPair(
                      sell: value,
                      buy: _orderBookProvider.activePair?.buy,
                    );
                  }),
            ),
            const SizedBox(width: 4),
            TextButton(
              key: const Key('coin-select-swap'),
              onPressed: () {
                _orderBookProvider.activePair = CoinsPair(
                  buy: _orderBookProvider.activePair?.sell,
                  sell: _orderBookProvider.activePair?.buy,
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                minimumSize: Size(40, 0),
              ),
              child: Icon(Icons.swap_horiz),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: CoinSelect(
                key: const Key('coin-select-right'),
                value: _orderBookProvider.activePair?.buy,
                type: CoinType.rel,
                pairedCoin: _orderBookProvider.activePair?.sell,
                autoOpen: _orderBookProvider.activePair?.buy == null &&
                    _orderBookProvider.activePair?.sell != null,
                compact: MediaQuery.of(context).size.width < 360,
                onChange: (Coin value) {
                  setState(() {
                    _showChart = false;
                  });
                  _orderBookProvider.activePair = CoinsPair(
                    buy: value,
                    sell: _orderBookProvider.activePair?.sell,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (_showChart)
          DurationSelect(
            value: _chartDuration,
            options: _durationData,
            disabled: _durationData == null,
            onChange: (String value) {
              setState(() {
                _chartDuration = value;
              });
            },
          ),
        Expanded(child: SizedBox()),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showChart = true;
            });
          },
          style: TextButton.styleFrom(
            primary: !_showChart
                ? settingsBloc.isLightTheme
                    ? cexColorLight
                    : cexColor.withOpacity(0.8)
                : Theme.of(context).colorScheme.secondary,
          ),
          icon: CandlesIcon(size: 14),
          label: Text(AppLocalizations.of(context).marketsChart),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _showChart = false;
            });
          },
          style: TextButton.styleFrom(
            primary: _showChart
                ? settingsBloc.isLightTheme
                    ? cexColorLight
                    : cexColor.withOpacity(0.8)
                : Theme.of(context).colorScheme.secondary,
          ),
          child: Text(AppLocalizations.of(context).marketsDepth),
        ),
      ],
    );
  }

  Widget _buildCandleChart() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 20.0,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: FutureBuilder<ChartData>(
          future: _cexProvider.getCandles(
            _pairStr,
            double.parse(_chartDuration),
          ),
          builder: (
            BuildContext context,
            AsyncSnapshot<ChartData> snapshot,
          ) {
            if (!snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _durationData = null;
                });
              });
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _durationData = snapshot.data.data.keys.toList();
              });
            });

            return StreamBuilder<Object>(
                initialData: settingsBloc.isLightTheme,
                stream: settingsBloc.outLightTheme,
                builder: (context, light) {
                  return CandleChart(
                      data: snapshot.data.data[_chartDuration],
                      duration: int.parse(_chartDuration),
                      textColor: light.data ? Colors.black : Colors.white,
                      gridColor: light.data
                          ? Colors.black.withOpacity(.2)
                          : Colors.white.withOpacity(.4));
                });
          },
        ),
      ),
    );
  }

  Widget _buildOrderBook() {
    if (!_hasBothCoins) {
      return Center(
        heightFactor: 10,
        child: Text(AppLocalizations.of(context).marketsSelectCoins),
      );
    }

    Orderbook _pairOrderBook;

    try {
      _pairOrderBook = _orderBookProvider.getOrderBook();
    } catch (_) {}

    if (_pairOrderBook == null) {
      return const Center(heightFactor: 10, child: CircularProgressIndicator());
    }

    final List<Ask> _sortedAsks =
        OrderBookProvider.sortByPrice(_pairOrderBook.asks);
    final List<Ask> _sortedBids =
        OrderBookProvider.sortByPrice(_pairOrderBook.bids, quotePrice: true);

    setState(() {
      listLength = max(_sortedBids.length, _sortedAsks.length);
    });

    return Column(
      children: <Widget>[
        _buildLimitButton(),
        Stack(
          children: <Widget>[
            OrderBookChart(
              sortedAsks: _cutToLimit(_sortedAsks),
              sortedBids: _cutToLimit(_sortedBids),
            ),
            OrderBookTable(
              sortedAsks: _cutToLimit(_sortedAsks),
              sortedBids: _cutToLimit(_sortedBids),
            ),
          ],
        ),
      ],
    );
  }

  List<Ask> _cutToLimit(List<Ask> uncutted) {
    if (uncutted.length <= listLimit) return uncutted;
    return uncutted.sublist(0, listLimit);
  }

  Widget _buildLimitButton() {
    if (listLength < listLimit && listLimit == listLimitMin) return SizedBox();

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Showing $listLimit of ${max(listLength, listLimit)} orders. ',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          if (listLimit > listLimitMin)
            InkWell(
                onTap: () {
                  setState(() {
                    listLimit -= listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )),
          if (listLength > listLimit)
            InkWell(
                onTap: () {
                  setState(() {
                    listLimit += listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
