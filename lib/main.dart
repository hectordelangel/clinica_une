import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class User {
  final bool correctUser;
  final String message;
  final int userId;
  final String username;
  final String email;
  User({
    this.correctUser,
    this.message,
    this.userId,
    this.username,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      correctUser: json["correct_user"],
      message: json["message"],
      userId: json["user_id"],
      username: json["username"],
      email: json["email"],
    );
  }
}

Future<User> fetchUser(String email, String password) async {
  final http.Response response = await http.post(
    'http://192.168.0.3/ClinicaUNE/api/validate_user.php',
    body: <String, String>{
      'email': email,
      'password': password,
    },
  );
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Fallo al traer el usuario');
  }
}

class Date {
  final List<dynamic> dates;
  Date({this.dates});

  factory Date.fromJson(Map<String, dynamic> json) {
    return Date(
      dates: json["dates"],
    );
  }
}

Future<Date> fetchDate(int userId) async {
  final response = await http.get(
      'http://192.168.0.3/ClinicaUNE/api/pending_appointments.php?user_id=' +
          userId.toString());
  if (response.statusCode == 200) {
    return Date.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Fallo al traer las citas');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(),
          '/menu': (context) => Menu(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<User> _futureUser;
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        child: (_futureUser == null)
            ? Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 5.0, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black,
                          offset: new Offset(10, 10),
                          blurRadius: 50.0,
                        )
                      ]),
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * .4,
                  child: Column(
                    // horizontal).
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Universidad del Noreste',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      Form(
                        child: Column(
                          children: [
                            Container(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: TextFormField(
                                      controller: _emailInputController,
                                      keyboardType: TextInputType.emailAddress,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email),
                                        labelText: "Email",
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 10.0, 20.0, 10.0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(32.0)),
                                      ),
                                    ))),
                            SizedBox(height: 15.0),
                            Container(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: TextFormField(
                                      controller: _passwordInputController,
                                      autofocus: false,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock),
                                        labelText: "Password",
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 10.0, 20.0, 10.0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(32.0)),
                                      ),
                                    ))),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: SizedBox(
                                  width: 200,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _futureUser = fetchUser(
                                            _emailInputController.text,
                                            _passwordInputController.text);
                                      });
                                    },
                                    color: Colors.red,
                                    child: Text('Log In',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : FutureBuilder<User>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.correctUser == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Dates(
                                    userId: snapshot.data.userId,
                                  )));
                    } else {
                      Center(child: Text("Usuario Incorrecto"));
                    }
                  } else if (snapshot.hasError) {
                    _futureUser = null;
                    return Text("${snapshot.error}");
                  }
                  return SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(child: CircularProgressIndicator()));
                },
              ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/une.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  final int userId;
  final String username;
  Menu({Key key, this.userId, this.username}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(username)),
        body: Center(),
        drawer: drawer(
          userId: userId,
        ));
  }
}

class Dates extends StatefulWidget {
  final int userId;
  Dates({Key key, this.userId}) : super(key: key);
  @override
  _DatesState createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  int userId;
  Future<Date> _futureDate;
  void initState() {
    super.initState();
    _futureDate = fetchDate(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clínica UNE")),
      body: Center(
        child: FutureBuilder<Date>(
          future: _futureDate,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return displayDates(snapshot.data);
            } else if (snapshot.hasError) {
              return Text(widget.userId.toString());
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      drawer: drawer(),
    );
  }

  Widget displayDates(Date listOfAppointments) {
    return ListView.builder(
        itemBuilder: (_, index) => Card(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(listOfAppointments.dates[index]["Nombre"]
                            .toString()),
                        width: 200,
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: Text(
                          listOfAppointments.dates[index]["Fecha"].toString()),
                      flex: 1,
                    ),
                    Expanded(
                      child: Text("Consultorio: " +
                          listOfAppointments.dates[index]["Consultorio"]
                              .toString()),
                      flex: 1,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
                padding: EdgeInsets.all(16),
              ),
            ),
        padding: const EdgeInsets.all(20.0),
        itemCount: listOfAppointments.dates.length);
  }
}

class drawer extends StatelessWidget {
  final int userId;
  drawer({Key key, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Clínica UNE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          ),
          ListTile(
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.body1,
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(Icons.receipt),
                    ),
                  ),
                  TextSpan(text: 'Citas'),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dates(userId: userId)));
            },
          ),
        ],
      ),
    );
  }
}
