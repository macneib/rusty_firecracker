import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';
// import 'package:simple_auth_flutter_example/api_definitions/youtubeApi.dart';
import 'package:rusty_firecracker/keycloak.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    SimpleAuthFlutter.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SimpleAuth Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'SimpleAuth Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


// final KeycloakConfig keycloakApi = new KeycloakConfig(
      // "identifier",
      // "client-id",
      // "client-secret",
      // "tokenURL",
      // "authURL",
//       "com.me.myapp://redirect",
//       scopes: ["openid"]);


  final simpleAuth.AmazonApi amazonApi = new simpleAuth.AmazonApi(
      "amazon",
      "amzn1.application-oa2-client.848f75b20206455097cde6b63ca53dec",
      "759db00c1a71fe308d55ce42387c510af8337a5b3aa402a835b77dc552766c3a",
      "http://localhost",
      scopes: ["clouddrive:read", "clouddrive:write"]);



  // final youtubeApi = new YoutubeApi("Youtube");
  @override
  Widget build(BuildContext context) {
    SimpleAuthFlutter.context = context;


    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
           ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login to Keycloak'),
            onTap: () {
              login(keycloakApi);
            },
          ),
           ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(amazonApi);
            },
          ),

        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(simpleAuth.AuthenticatedApi api) async {
    try {
      var success = await api.authenticate();
      showMessage("Logged in success: $success");
    } catch (e) {
      showError(e);
    }
  }

  void logout(simpleAuth.AuthenticatedApi api) async {
    await api.logOut();
    showMessage("Logged out");
  }
}


class KeycloakAuth {
  KeycloakAuth._privateConstructor();

  static final KeycloakAuth _instance = KeycloakAuth._privateConstructor();

  static KeycloakAuth get instance {
    return _instance;
  }

  // ignore: non_constant_identifier_names
  final KeycloakConfig KC_OAuth = new KeycloakConfig(
      "identifier",
      "client-id",
      "client-secret",
      "tokenURL",
      "authURL",
      "com.me.myapp://redirect",
      scopes: ["openid"]);

  Future<http.Response> logout() async {
    KC_OAuth.logOut();
    final response = await KC_OAuth.httpClient.get(
        'endSessionEndpoint');
    return response;
  }

  Map<String, String> getAuthHeaders() {
    return {'Authorization': 'Bearer ${KC_OAuth.currentOauthAccount.token}'};
  }

  Future<KeycloakUser> getKeycloakUser() async {
    final response = await http.get(
        "userInfoEndpoint",
        headers: getAuthHeaders());
    if (response.statusCode == 200) {
      return KeycloakUser.fromJson(json.decode(response.body));
    } else
      return null;
  }
}

class KeycloakUser {
  String _sub;
  bool _emailVerified;
  String _name;
  String _preferredUsername;
  String _givenName;
  String _familyName;
  String _email;

  KeycloakUser.fromJson(Map<String, dynamic> parsedJson) {
    _sub = parsedJson['sub'];
    _emailVerified = parsedJson['email_verified'];
    _name = parsedJson['name'];
    _preferredUsername = parsedJson['preferred_username'];
    _givenName = parsedJson['given_name'];
    _familyName = parsedJson['family_name'];
    _email = parsedJson['email'];
  }

  String get sub => _sub;
  bool get emailVerified => _emailVerified;
  String get name => _name;
  String get preferredUsername => _preferredUsername;
  String get givenName => _givenName;
  String get familyName => _familyName;
  String get email => _email;
}