import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/addressbook/contact_edit.dart';
import 'package:komodo_dex/screens/addressbook/contacts_list.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/widgets/round_button.dart';
import 'package:provider/provider.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({
    this.coin,
    this.shouldPop = false,
    this.contact,
  });

  final Coin coin;
  final bool shouldPop;
  final Contact contact;

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBookPage> {
  AddressBookProvider provider;
  Coin coin;
  bool isSearchOpen = false;
  String searchPhrase = '';

  @override
  void initState() {
    coin = widget.coin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.contact == null
                ? AppLocalizations.of(context).addressBookTitle
                : AppLocalizations.of(context).contactTitle,
            key: const Key('addressbook-title'),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.contact == null) _buildHeader(),
            if (widget.contact == null) _buildActiveFilters(),
            Expanded(
              child: FutureBuilder(
                future: provider.contacts,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Contact>> snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<Contact> contacts = List.from(snapshot.data);
                  contacts.sort((Contact a, Contact b) {
                    return a.name.compareTo(b.name);
                  });

                  if (contacts.isEmpty)
                    return Center(
                        child: Text(
                            AppLocalizations.of(context).addressBookEmpty));

                  return ContactsList(
                    contacts,
                    shouldPop: widget.shouldPop,
                    coin: coin,
                    contact: widget.contact,
                    searchPhrase: searchPhrase,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isSearchOpen ? _buildSearchBar() : _buildToolBar(),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          child: TextField(
            autofocus: true,
            onChanged: (String value) {
              setState(() {
                searchPhrase = value;
              });
            },
          ),
        )),
        const SizedBox(width: 4),
        RoundButton(
          onPressed: () {
            setState(() {
              searchPhrase = '';
              isSearchOpen = false;
            });
          },
          child: Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RoundButton(
          onPressed: () {
            Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const ContactEdit(
                    contact: null,
                  ),
                ));
          },
          child: Icon(Icons.add),
        ),
        const SizedBox(width: 4),
        RoundButton(
          onPressed: () {
            setState(() {
              isSearchOpen = true;
            });
          },
          child: Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    if (coin == null) return Container();

    String title = coin.abbr;

    if (coin.type == 'smartChain') title = 'KMD & SmartChains';
    if (coin.type == 'erc') title = 'ETH & ERC tokens';
    if (coin.type == 'bep') title = 'BNB & BEP tokens';
    if (coin.type == 'qrc' || coin.abbr == 'QTUM') title = 'QTUM & QRC tokens';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          AppLocalizations.of(context).addressBookFilter(title),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}