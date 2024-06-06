import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/widgets/navbar.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final String title;

  const BaseScreen({required this.body, required this.title, Key? key, FloatingActionButton? floatingActionButton,  FloatingActionButtonLocation, floatingActionButtonLocation, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: NavBar(),
      body: body,
    );
  }
}
