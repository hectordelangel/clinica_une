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
  final int user_id;
  final String username;
  final String email;
  final String password;
  User({this.correctUser, this.message, this.user_id, this.username, this.email, this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      correctUser: json["correct_user"],
      message: json["message"],
      user_id: json["user_id"],
      username: json["username"],
      email: json["email"],
      password: json["password"],
    );
  }
}

Future<User> fetchUser(String email, String password) async {
  final http.Response response = await http.post(
    'http://192.168.56.1/ClinicaUNE/api/validate_user.php',
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

Future<Date> fetchDate(int user_id) async {
  final response = await http.get('http://192.168.56.1/ClinicaUNE/api/pending_appointments.php?user_id='+user_id.toString());
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
          '/patients': (context) => Patient(),
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
                      Navigator.push(context,MaterialPageRoute(
                          builder: (context) => Menu(user_id: snapshot.data.user_id, username: snapshot.data.username)));
                    } else {
                      Center(child: Text("Usuario Incorrecto"));
                    }
                  } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                      _futureUser = null;


                  }
                  return SizedBox(width:80, height: 80 ,child:Center(child: CircularProgressIndicator()));
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
  final int user_id;
  final String username;
  Menu({Key key, this.user_id, this.username}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(username)),
        body: Center(),
        drawer: drawer(user_id: user_id,));
  }
}


// class Menu extends StatefulWidget {
//   @override
//   _MenuState createState() => _MenuState();
// }
//
// class _MenuState extends State<Menu> {
//   Future<User> futureUser;
//   final User user;
//   _MenuState({Key key, this.user}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text(user.)),
//         body: Center(),
//         drawer: drawer());
//   }
// }

class Patient extends StatefulWidget {
  @override
  _PatientState createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameInputController = TextEditingController();
  final _recordNumberInputController = TextEditingController();
  final _patientAgeInputController = TextEditingController();
  final _patientGenderInputController = TextEditingController();
  final _patientAddressInputController = TextEditingController();
  final _patientPhoneInputController = TextEditingController();
  final _relativeNameInputController = TextEditingController();
  final _relativeAddressInputController = TextEditingController();
  final _relativePhoneInputController = TextEditingController();
  final _patientOccupationInputController = TextEditingController();
  final _patientBloodTypeInputController = TextEditingController();
  final _patientRHInputController = TextEditingController();
  final _patientDrugsAllergyInputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clínica UNE")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField(_patientNameInputController, "Nombre"),
              _buildInputField(
                  _recordNumberInputController, "No de expediente"),
              _buildInputField(_patientAgeInputController, "Edad"),
              _buildInputField(_patientGenderInputController, "Sexo"),
              _buildInputField(
                  _patientAddressInputController, "Domicilio del paciente"),
              _buildInputField(_patientPhoneInputController, "Teléfono"),
              _buildInputField(
                  _relativeNameInputController, "Familiar responsable"),
              _buildInputField(
                  _relativeAddressInputController, "Domicilio del responsable"),
              _buildInputField(
                  _relativePhoneInputController, "Telefono del responsable"),
              _buildInputField(
                  _patientOccupationInputController, "Ocupación del paciente"),
              _buildInputField(_patientDrugsAllergyInputController,
                  "Alergia a medicamentos"),
              _buildInputField(
                  _patientBloodTypeInputController, "Grupo Sanguineo"),
              _buildInputField(_patientRHInputController, "Rh"),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: RaisedButton(
                        child: Text('Crear'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {}
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: RaisedButton(
                        child: Text('Regresar'),
                        onPressed: () {
                          Navigator.pushNamed(context, "/Menu");
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      drawer: drawer(),
    );
  }

  Container _buildInputField(controller, text) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Flexible(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
                style: TextStyle(fontWeight: FontWeight.bold),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
                controller: controller,
                decoration: InputDecoration(
                  labelText: (text),
                )),
          ),
        ));
  }
}

class Dates extends StatefulWidget {
  int user_id;
  Dates({Key key, this.user_id}) : super(key: key);
  @override
  _DatesState createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  int user_id;
  Future<Date> _futureDate;
  void initState() {
    super.initState();
    _futureDate = fetchDate(widget.user_id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clínica UNE")),
      body: SingleChildScrollView(
        child: FutureBuilder<Date>(
        future: _futureDate,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var dates = display_dates(snapshot.data);
            return ListView(children: dates,);

          } else if (snapshot.hasError) {
            return Text(widget.user_id.toString());
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
      ),
      drawer: drawer(),
    );
  }

  List<Widget> display_dates(Date date){
    List<Widget> list = [];
    for (var dates in date.dates)
      list.add(
          Card(child: Container(child: Row(
            children: [
              Expanded(
                child: Container(
                  child:Text(dates["Nombre"]),
                  width: 200,
                ),
                flex: 1,
              ),
              Expanded(
                child: Text(dates["Fecha"]),
                flex: 2,
              ),
              Expanded(
                child: Text("Consultorio "+dates["Consultorio"]),
                flex: 2,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
            padding: EdgeInsets.all(16),
          ),
          )

      );
    return list;
  }

}


class drawer extends StatelessWidget {
  final int user_id;
  drawer({Key key, this.user_id}) : super(key: key);
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
              Navigator.push(context,MaterialPageRoute(
                  builder: (context) => Dates(user_id: user_id)));
            },
          ),
        ],
      ),
    );
  }
}
