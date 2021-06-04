import 'dart:convert';

import 'package:Postly/lastUser.dart';
import 'package:Postly/user.dart';
import 'package:Postly/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

final user = UserAPI();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // await DotEnv(env: appModel.env).load('assets/.env');

    final lastUser = await Postly.storage.read(key: 'savedUser');
    if (lastUser != null && lastUser.isNotEmpty) {
      user.laastUser = LastUserModel.fromJson(json.decode(lastUser));
    }
  } catch (e, t) {
    print(e);
    print(t);
  }

  runApp(Postly());
}

class Postly extends StatelessWidget {
  static final FlutterSecureStorage storage = FlutterSecureStorage();
  static bool isUserAvail = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: UserAPI()),
      ],
      child: MaterialApp(
        title: 'Postly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Posts'),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserModel user;
  LastUserModel luser;

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (value) async {
        if (Postly.isUserAvail == true) {
          print('User is Available');
          await Provider.of<UserAPI>(context, listen: false).getSavedUser();
          luser = Provider.of<UserAPI>(context, listen: false).lastUser;
          print("LUSER MAIL ${luser.email}");
        }
        await Provider.of<UserAPI>(context, listen: false).getUsers();
        user = Provider.of<UserAPI>(context, listen: false).randomUser;
      },
    );

    super.initState();
  }

  bool get usernotAvail => user?.email == null || user.email.isEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<UserAPI>(context, listen: false).getSavedUser(),
      // ignore: missing_return
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        } else
          return Scaffold(
            appBar: AppBar(
              title: Text('Welcome ${usernotAvail ? luser?.email : user.name}'),
            ),
            body: GestureDetector(
              onTap: () {
                print(Postly.isUserAvail);
              },
              child: Center(
                child: Text(usernotAvail ? widget.title : user.email),
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
      },
    );
  }
}
