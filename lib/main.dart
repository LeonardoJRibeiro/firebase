import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Initial();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}

class Initial extends StatelessWidget {
  const Initial({Key? key}) : super(key: key);

  Future<void> addUser() async {
    final resultado = await FirebaseFirestore.instance.collection('users').add(
      {
        'nome': 'Leonardo',
        'email': 'leonardojr410@gmail.com',
      },
    );
    print(resultado);
  }

  Future<void> getUsers() async {
    final resultado = await FirebaseFirestore.instance.collection('users').get();
    print(resultado.docs.map((e) => e['nome']));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextButton(
              onPressed: () => addUser(),
              child: Text('salvar'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return new ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                      return new ListTile(
                        title: new Text('${data['nome']}'),
                        subtitle: new Text('${data['email']}'),
                        leading: IconButton(
                          onPressed: () async {
                            await document.reference.update({
                              'nome': 'Léo',
                              'email': 'leonardojr410@gmail.com',
                            });
                          },
                          icon: Icon(Icons.delete),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            await document.reference.update({
                              'nome': 'Léo',
                              'email': 'leonardojr410@gmail.com',
                            });
                          },
                          icon: Icon(Icons.edit),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
