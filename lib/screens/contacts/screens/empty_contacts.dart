import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/views/contacts.dart';
import 'package:fusecash/screens/contacts/screens/send_to_account.dart';
import 'package:fusecash/screens/contacts/widgets/enable_contacts.dart';
import 'package:fusecash/screens/contacts/router/router_contacts.gr.dart';
import 'package:fusecash/screens/contacts/widgets/search_panel.dart';
import 'package:fusecash/utils/contacts.dart';
import 'package:fusecash/widgets/main_scaffold.dart';
import "package:ethereum_address/ethereum_address.dart";

class EmptyContacts extends StatefulWidget {
  @override
  _EmptyContactsState createState() => _EmptyContactsState();
}

class _EmptyContactsState extends State<EmptyContacts> {
  bool showFooter = true;
  bool hasSynced = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void resetSearch() {
    FocusScope.of(context).unfocus();
    if (mounted) {
      setState(() {
        searchController.text = '';
      });
    }
  }
  List<Widget> _buildPageList(ContactsViewModel viewModel) {
    List<Widget> listItems = List();

    listItems.add(SearchPanel(
      searchController: searchController,
    ));

    if (isValidEthereumAddress(searchController.text)) {
      listItems.add(SendToAccount(
        accountAddress: searchController.text,
        resetSearch: resetSearch,
      ));
    }

    listItems.add(SliverList(
      delegate: SliverChildListDelegate([
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 100),
              child: SvgPicture.asset(
                'assets/images/contacts.svg',
                width: 70.0,
                height: 70,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(I18n.of(context).sync_your_contacts),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Text(I18n.of(context).learn_more),
                  onTap: () {
                    showDialog(
                        child: ContactsConfirmationScreen(), context: context);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          I18n.of(context).activate,
                          style: TextStyle(color: Color(0xFF0377FF)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset('assets/images/blue_arrow.svg')
                      ],
                    ),
                    onTap: () async {
                      bool premission =
                          await ContactController.getPermissions();
                      if (premission) {
                        List<Contact> contacts =
                            await ContactController.getContacts();
                        viewModel.syncContacts(contacts);
                        ExtendedNavigator.named('contactsRouter')
                            .replace(ContactsRoutes.contactsList);
                        viewModel
                            .trackCall("Wallet: Contacts Permission Granted");
                        viewModel.idenyifyCall(
                            Map.from({"Contacts Permission Granted": false}));
                        setState(() {
                          hasSynced = true;
                        });
                      } else {
                        viewModel
                            .trackCall("Wallet: Contacts Permission Rejected");
                        viewModel.idenyifyCall(
                            Map.from({"Contacts Permission Granted": false}));
                      }
                    })
              ],
            )
          ],
        )
      ]),
    ));

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ContactsViewModel>(
        distinct: true,
        converter: ContactsViewModel.fromStore,
        builder: (_, viewModel) {
          return MainScaffold(
            automaticallyImplyLeading: false,
            title: I18n.of(context).send_to,
            sliverList: _buildPageList(viewModel),
          );
        });
  }
}
