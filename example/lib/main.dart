import 'package:flutter/material.dart';

import 'db.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'data.appName',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MyHomePage(),
  );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('widget.title'),
    ),
    body: FutureBuilder<List<Account>>(
      initialData: [],
      future: _init(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, position) {
              return ListTile(
                title: Text(snapshot.data[position].name),
              );
            },
          );
        } else {
          return Text('loading...');
        }
      },
    ),
  );

  Future<List<Account>> _init() async {
    MyDatabase db = DatabaseFactory.getDatabase<MyDatabase>();
    AccountDao dao = db.accountDao();
    List.generate(10, (i) => i + 1).forEach((i) async {
      Account account = Account();
      account.id = i;
      account.name = 'test_$i';
      await dao.insert(account);
    });
    return dao.getAll();
  }
}
