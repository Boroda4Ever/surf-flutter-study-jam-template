import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../topics/repository/chart_topics_repository.dart';
import '../../topics/screens/topics_screen.dart';
import '../exceptions/auth_exception.dart';

class AuthScreen extends StatefulWidget {
  final IAuthRepository authRepository;

  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color primaryColor = Color(0xFF13B5A2);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Create storage
  final _storage = const FlutterSecureStorage();

  final TextEditingController _usernameController =
      TextEditingController(text: "");
  final TextEditingController _passwordController =
      TextEditingController(text: "");

  bool passwordHidden = true;
  bool _savePassword = true;

  String? token;

  // Future<TokenDto?> getToken(BuildContext context) async {
  //   try {
  //     TokenDto token = await widget.authRepository.signIn(
  //         login: _usernameController.text, password: _passwordController.text);
  //     return token;
  //   } on AuthException catch (_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Error! Invalid login or password.'),
  //       ),
  //     );
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Got error : $error.'),
  //       ),
  //     );
  //   }
  //   return null;
  // }

  // Read values
  Future<String?> _readFromStorage() async {
    token = await _storage.read(key: "USER_TOKEN");
  }

  Future<TokenDto?> _onFormSubmit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        TokenDto token = await widget.authRepository.signIn(
            login: _usernameController.text,
            password: _passwordController.text);
        _storage.write(key: "USER_TOKEN", value: token.token);
        _storage.write(key: "USER_NAME", value: token.token);
        return token;
      } on AuthException catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error! Invalid login or password.'),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Got error : $error.'),
          ),
        );
      }
    }
  }

  final _loginFocus = FocusNode();
  final _passwordFocus = FocusNode();

  _launchURL() async {
    Uri uri = Uri.parse("https://flutter.io");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // can't launch url
    }
  }

  @override
  void initState() {
    super.initState();
    _readFromStorage();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> _pushToChat(BuildContext context, TokenDto token) async {
    StudyJamClient client = StudyJamClient().getAuthorizedClient(token.token);
    SjUserDto? user = await client.getUser();
    _storage.write(key: "USER_TOKEN", value: token.token);
    _storage.write(key: "USER_NAME", value: user != null ? user.username : '');
    Navigator.push<TopicsScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return TopicsScreen(token: token.token);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _readFromStorage();
    Color random =
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: size.width,
              padding: EdgeInsets.all(size.width - size.width * .85),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * .10,
                  ),
                  const Text(
                    "Добро пожаловать",
                    style: TextStyle(
                        color: Color(0xFF161925),
                        fontWeight: FontWeight.w600,
                        fontSize: 32),
                  ),
                  SizedBox(
                    height: size.height * .15,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          onTap: (() => setState(() {})),
                          focusNode: _loginFocus,
                          autofocus: true,
                          onFieldSubmitted: (_) {
                            setState(() {
                              _fieldFocusChange(
                                  context, _loginFocus, _passwordFocus);
                            });
                          },
                          onChanged: ((value) => setState(() {})),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: _usernameController.text.isNotEmpty
                                    ? primaryColor
                                    : Color(0xff747881)),
                            labelText: "Логин",
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF000000),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: _usernameController.text.isNotEmpty
                                    ? primaryColor
                                    : Color(0xff747881)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                          ),
                          controller: _usernameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Заполните поле';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        TextFormField(
                          onChanged: ((value) => setState(() {})),
                          onFieldSubmitted: (_) {
                            setState(() {
                              _passwordFocus.unfocus();
                              _onFormSubmit(context).then(
                                (token) {
                                  if (token != null) {
                                    _pushToChat(context, token);
                                  }
                                },
                              );
                            });
                          },
                          onTap: (() => setState(() {})),
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            return value!.isEmpty ? "Заполните поле" : null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock,
                                color: _passwordController.text.isNotEmpty
                                    ? primaryColor
                                    : Color(0xff747881)),
                            labelText: "Пароль",
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF000000),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: _passwordController.text.isNotEmpty
                                    ? primaryColor
                                    : Color(0xff747881)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  passwordHidden = !passwordHidden;
                                });
                              },
                              child: Icon(
                                passwordHidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _passwordController.text.isNotEmpty
                                    ? primaryColor
                                    : Color(0xff747881),
                                size: 23,
                              ),
                            ),
                          ),
                          controller: _passwordController,
                          obscureText: passwordHidden,
                          enableSuggestions: false,
                          toolbarOptions: const ToolbarOptions(
                            copy: false,
                            paste: false,
                            cut: false,
                            selectAll: false,
                            //by default all are disabled 'false'
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * .045,
                  ),
                  CheckboxListTile(
                    value: _savePassword,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _savePassword = newValue!;
                      });
                    },
                    title: const Text("Оставаться в аккаунте"),
                    activeColor: primaryColor,
                  ),
                  SizedBox(
                    height: size.height * .03,
                  ),
                  SizedBox(
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () => {
                        _onFormSubmit(context).then(
                          (token) {
                            if (token != null) {
                              _pushToChat(context, token);
                            }
                          },
                        )
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          textStyle: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      child: const Text("Далее"),
                    ),
                  ),
                  SizedBox(
                    height: size.height * .035,
                  ),
                  const Center(
                    child: Text(
                      "У вас всё еще нет аккаунта?",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: size.height * .01,
                  ),
                  Center(
                    child: InkWell(
                      onTap: _launchURL,
                      child: const Text(
                        "Получить логин и пароль.",
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
