import 'package:cimo_mobile/fetch_registered_city.dart';
import 'package:cimo_mobile/home.dart';
import 'package:cimo_mobile/jwt_init.dart';
import 'package:cimo_mobile/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cimo_mobile/fetch_general.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String status = '';
  String loadingmessage = 'Please wait';
  bool loadingstatus = true;
  bool isauthentic = false;
  String? token = '';
  String? devid = '';
  String? key = '';

  void check() async {
    String? new_token = '';
    String? new_key = '';
    String? new_id = '';
    String? prev_token = '';
    String? prev_key = '';
    String? prev_id = '';
    Prefs sess = Prefs(value: '', key: '');
    await sess.getter('token');
    if (sess.res == null || sess.res == '') {
      JWT jwt = JWT(status: 'None', key: 'None', id: 'None');
      await jwt.getjwt();
      await sess.getter('token');
      new_token = sess.res;
      await sess.getter('key');
      new_key = sess.res;
      await sess.getter('id');
      new_id = sess.res;
      JWT newjwt = JWT(status: new_token, key: new_key, id: new_id);
      await newjwt.getjwt();
      print(newjwt.jwt);
      if (newjwt.jwt[0]['status'] == 'Success') {
        setState(() {
          isauthentic = true;
          token = new_token;
          key = new_key;
          devid = new_id;
          print(devid);
        });
        initializegeneraldata();
      } else {
        setState(() {
          loadingmessage = newjwt.jwt[0]['status'];
          loadingstatus = false;
        });
      }
    } else {
      await sess.getter('token');
      prev_token = sess.res;
      await sess.getter('key');
      prev_key = sess.res;
      await sess.getter('id');
      prev_id = sess.res;
      JWT prevtoken = JWT(status: prev_token, key: prev_key, id: prev_id);
      await prevtoken.getjwt();
      if (prevtoken.jwt[0]['status'] == 'Success') {
        setState(() {
          isauthentic = true;
          token = prev_token;
          key = prev_key;
          devid = prev_id;
          print(devid);
        });
        initializegeneraldata();
      } else {
        setState(() {
          loadingmessage = prevtoken.jwt[0]['status'];
          loadingstatus = false;
        });
      }
    }
  }

  void initializegeneraldata() async {
    if (isauthentic == true) {
      FetchGeneralData initialData =
          FetchGeneralData(token: token, key: key, id: devid);
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          loadingmessage = 'Checking your Internet';
        });
      });
      await initialData.getData();
      List initData = initialData.data;
      print(initData);
      FetchRegisteredCity registeredCity = FetchRegisteredCity();
      await Future.delayed(
        Duration(seconds: 3),
        () {
          setState(() {
            loadingmessage = 'Getting Registered Establishments';
          });
        },
      );
      await registeredCity.getData();
      List initialCity = registeredCity.data;
      print(initialCity);
      await Future.delayed(
        Duration(seconds: 3),
        () {
          setState(() {
            loadingmessage = 'Finalizing';
          });
        },
      );
      Future.delayed(
        Duration(seconds: 3),
        () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeView(
                data: initData,
                city: initialCity,
                token: token,
                secretkey: key,
                id: devid,
              ),
            ),
          );
        },
      );
    } else {
      print('ez');
    }
  }

  @override
  void initState() {
    super.initState();
    check();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xffFDF6EE),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffFDF6EE),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Container(
                  height: 230,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage(
                          'assets/images/logo.png',
                        ),
                        height: 80,
                        width: 80,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'CIMO',
                        style: TextStyle(
                          fontFamily: 'Montserrat-B',
                          fontSize: 35,
                          color: Color(0xffA9D8D5),
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color(0xff616161),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        '$loadingmessage',
                        style: TextStyle(
                          fontFamily: 'Montserrat-B',
                          fontSize: 12,
                          color: Color(0xff573240),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      loadingstatus == true
                          ? SpinKitThreeBounce(
                              size: 20,
                              color: Color(0xffFCD4D0),
                            )
                          : Icon(
                              Icons.wifi_off_rounded,
                              size: 20,
                              color: Color(0xffcccccc),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
                child: Text(
                  'Crowd Counting with Integrative Mobile Application',
                  style: TextStyle(
                    fontFamily: 'Montserrat-R',
                    fontSize: 11,
                    color: Color(0xff808080),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
