import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gooddollar/generated/i18n.dart';
import 'package:gooddollar/models/app_state.dart';
import 'package:gooddollar/models/views/splash.dart';
import 'package:gooddollar/screens/routes.gr.dart';
import 'package:gooddollar/widgets/primary_button.dart';
import 'package:gooddollar/widgets/transparent_button.dart';

class WarnBeforeReCreation extends StatefulWidget {
  @override
  _WarnBeforeReCreationState createState() => _WarnBeforeReCreationState();
}

class _WarnBeforeReCreationState extends State<WarnBeforeReCreation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimatoin;
  bool isPreloading = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    scaleAnimatoin =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext _context) {
    return ScaleTransition(
        scale: scaleAnimatoin,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(
            child: SvgPicture.asset(
              'assets/images/important.svg',
              width: 35,
              height: 35,
            ),
          ),
          content: Text(
              'Creating a new account will reset your existing account - are you sure you want to continue?'),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFF009DFF),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              child: Text(I18n.of(context).yes, style: TextStyle(fontSize: 16)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false);
              },
              child: Text(I18n.of(context).no, style: TextStyle(fontSize: 16)),
            ),
          ],
        ));
  }
}

class CreateWallet extends StatefulWidget {
  @override
  _CreateWalletState createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  bool isPrimaryPreloading = false;
  bool isTransparentPreloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SplashViewModel>(
        distinct: true,
        converter: SplashViewModel.fromStore,
        builder: (_, viewModel) {
          return Container(
            padding: EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 200,
                  child: Image.asset('assets/images/illustration.png'),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    'GoodDollar Wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'GoodDollar is a digital coin and wallet\n that allows you to receive FREE income\n with real monetary value straight to your phone!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 50,
                ),
                PrimaryButton(
                  width: MediaQuery.of(context).size.width,
                  fontSize: 20,
                  labelFontWeight: FontWeight.normal,
                  disabled: isPrimaryPreloading,
                  label: viewModel.isLoggedOut
                      ? I18n.of(context).login
                      : I18n.of(context).create_new_wallet,
                  onPressed: () async {
                    if (viewModel.isLoggedOut) {
                      viewModel.loginAgain();
                      ExtendedNavigator.root.replace(Routes.homePage);
                    } else {
                      viewModel.setDeviceIdCall();
                      viewModel.createLocalAccount(() {
                        setState(() {
                          isPrimaryPreloading = false;
                        });
                        ExtendedNavigator.root.pushSignupScreen();
                      });
                      setState(() {
                        isPrimaryPreloading = true;
                      });
                    }
                  },
                  preload: isPrimaryPreloading,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: viewModel.isLoggedOut
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TransparentButton(
                                  fontSize: 14,
                                  label: I18n.of(context).restore_backup,
                                  onPressed: () async {
                                    ExtendedNavigator.root.pushRecoveryPage();
                                  }),
                              Text(
                                I18n.of(context).or,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              TransparentButton(
                                  fontSize: 14,
                                  label: I18n.of(context).create__wallet,
                                  onPressed: () async {
                                    bool result = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WarnBeforeReCreation();
                                      },
                                    );
                                    if (result) {
                                      viewModel.setDeviceIdCall();
                                      viewModel.createLocalAccount(() {
                                        setState(() {
                                          isTransparentPreloading = false;
                                        });
                                        ExtendedNavigator.root
                                            .pushSignupScreen();
                                      });
                                      setState(() {
                                        isTransparentPreloading = true;
                                      });
                                    }
                                  },
                                  preload: isTransparentPreloading)
                            ],
                          )
                        : TransparentButton(
                            fontSize: 20,
                            label: I18n.of(context).restore_from_backup,
                            onPressed: () async {
                              ExtendedNavigator.root.pushRecoveryPage();
                            }))
              ],
            ),
          );
        });
  }
}
