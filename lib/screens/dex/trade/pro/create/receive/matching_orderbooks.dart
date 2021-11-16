import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/receive/matching_orderbook_item.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:provider/provider.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';

class MatchingOrderbooks extends StatefulWidget {
  const MatchingOrderbooks({
    Key key,
    this.sellAmount,
    this.onCreatePressed,
    this.onBidSelected,
    this.orderbooksDepth,
  }) : super(key: key);

  final double sellAmount;
  final Function(String) onCreatePressed;
  final Function(Ask) onBidSelected;
  final List<OrderbookDepth> orderbooksDepth; // for integration tests

  @override
  _MatchingOrderbooksState createState() => _MatchingOrderbooksState();
}

class _MatchingOrderbooksState extends State<MatchingOrderbooks> {
  OrderBookProvider orderBookProvider;
  final searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    orderBookProvider = Provider.of<OrderBookProvider>(context);
    final List<OrderbookDepth> orderbooksDepth =
        widget.orderbooksDepth ?? orderBookProvider.depthsForCoin();

    return StatefulBuilder(builder: (context, setState) {
      return CustomSimpleDialog(
        hasHorizontalPadding: false,
        title: Text(AppLocalizations.of(context).receiveLower),
        key: const Key('receive-list-coins'),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchTextController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyText2.color,
                ),
                hintText: 'Search for Ticker',
                hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withAlpha(180)),
                counterText: '',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).accentColor),
                ),
              ),
              maxLength: 16,
            ),
          ),
          ...orderbooksDepth
              .where((obDepth) {
                final coinBalance =
                    coinsBloc.getBalanceByAbbr(obDepth.pair.rel);
                return coinBalance != null && !coinBalance.coin.walletOnly;
              })
              .where((obDepth) {
                final String searchTerm =
                    searchTextController.text.trim().toLowerCase();
                final Coin relCoin = coinsBloc.getCoinByAbbr(obDepth.pair.rel);

                return relCoin.abbr.toLowerCase().contains(searchTerm) ||
                    relCoin.name.toLowerCase().contains(searchTerm);
              })
              .map((OrderbookDepth obDepth) => MatchingOrderbookItem(
                  key: ValueKey(
                      'orderbook-item-${obDepth.pair.rel.toLowerCase()}'),
                  orderbookDepth: obDepth,
                  onCreatePressed: widget.onCreatePressed,
                  onBidSelected: widget.onBidSelected,
                  sellAmount: widget.sellAmount))
              .toList(),
        ],
      );
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }
}

class CreateOrder extends StatelessWidget {
  const CreateOrder({this.onCreateNoOrder, this.coin});
  final Function(String) onCreateNoOrder;
  final String coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () {
          onCreateNoOrder(coin);
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                AppLocalizations.of(context).noOrderAvailable,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).accentColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}