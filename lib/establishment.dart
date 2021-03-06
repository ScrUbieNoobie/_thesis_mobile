import 'dart:collection';
import 'package:cimo_mobile/unsupported.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cimo_mobile/specific_establishment.dart';
import 'package:flutter/services.dart';
import 'package:cimo_mobile/ip.dart';

// ignore: must_be_immutable
class EstablishmentInfo extends StatefulWidget {
  String id;
  String hero_tag;
  String? token = '';
  String? secretkey = '';
  String? devid = '';
  EstablishmentInfo({
    required this.id,
    required this.hero_tag,
    required this.token,
    required this.secretkey,
    required this.devid,
  });
  @override
  _EstablishmentInfoState createState() => _EstablishmentInfoState();
}

class _EstablishmentInfoState extends State<EstablishmentInfo> {
  String color_status = '';
  bool isload = true;
  bool set_img = false;
  List specdata = [];
  late GoogleMapController _mapController;
  Set<Marker> _markers = HashSet<Marker>();
  Future _mapfuture = Future.delayed(
    Duration(seconds: 3),
    () => true,
  );

  GetIp address = GetIp();

  void getSpecific(String id) async {
    //ignore: non_constant_identifier_names
    SpecificEstablishment spec_instance = SpecificEstablishment(
        refid: id,
        token: widget.token,
        key: widget.secretkey,
        id: widget.devid);
    await spec_instance.getSpec();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isload = false;
        set_img = true;
        specdata = spec_instance.data;
      });
      status(specdata[0]['status']);
    });
  }

  void status(status) {
    setState(() {
      color_status = status;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("0"),
          position: LatLng(
            double.parse(specdata[0]['latitude']),
            double.parse(specdata[0]['longitude']),
          ),
        ),
      );
    });
  }

  void updateData(String id) async {
    SpecificEstablishment specinstanceupdated = SpecificEstablishment(
        refid: id,
        token: widget.token,
        key: widget.secretkey,
        id: widget.devid);
    await specinstanceupdated.getSpec();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isload = false;
        specdata = specinstanceupdated.data;
      });
      status(specdata[0]['status']);
    });
  }

  @override
  void initState() {
    super.initState();
    getSpecific(widget.id);
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
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    if (MediaQuery.of(context).size.width < 300 ||
        MediaQuery.of(context).size.width > 768) {
      return buildunsupported(context);
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Color(0xff616161),
          ),
          backgroundColor: Color(0xffFDF6EE),
          elevation: 3,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: EdgeInsets.only(
                  right: 10,
                ),
                height: 35,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Hero(
                  tag: widget.hero_tag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: set_img == false
                        ? Image(
                            image: AssetImage('assets/images/logo.png'),
                          )
                        : specdata[0]['logo'] == "none"
                            ? Image(
                                image: AssetImage('assets/images/logo.png'),
                              )
                            : Image(
                                image: NetworkImage(
                                    'http://${address.getip()}:80/cimo_desktop/uploads/${specdata[0]['logo']}'),
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: isload == true ? BuildLoad() : BuildBody(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xffFF6E00),
          elevation: 2,
          onPressed: () {
            setState(() {
              isload = true;
            });
            updateData(widget.id);
          },
          child: Icon(
            Icons.refresh_rounded,
          ),
        ),
      );
    }
  }

  Widget BuildBody() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Color(0xffFDF6EE),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
              future: _mapfuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitRipple(
                    color: Color(0xffFCD4D0),
                    size: 40,
                    borderWidth: 10,
                  );
                }
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.parse(specdata[0]['latitude']),
                      double.parse(specdata[0]['longitude']),
                    ),
                    zoom: 12,
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.37,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        ' - ${specdata[0]['establishment-name']}',
                        style: TextStyle(
                          fontFamily: 'Montserrat-B',
                          fontSize: 22,
                          color: Color(0xff573240),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.circle_rounded,
                        size: 10,
                        color: color_status == 'normal'
                            ? Colors.green
                            : color_status == 'full'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '$color_status',
                        style: TextStyle(
                          fontFamily: 'Montserrat-R',
                          fontSize: 12,
                          color: Color(0xff573240),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.location_pin,
                        color: Color(0xffFF6E00),
                        size: 17,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: Text(
                          '${specdata[0]['branch']}, ${specdata[0]['street']}, ${specdata[0]['barangay']}, ${specdata[0]['city']}, ${specdata[0]['province']}, Philippines',
                          style: TextStyle(
                            fontFamily: 'Montserrat-R',
                            fontSize: 15,
                            color: Color(0xff573240),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Color(0xffFDE5E3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Allowable | Normal',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xff573240),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    '${specdata[0]['limited-capacity']} | ${specdata[0]['normal-capacity']}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xffFF6F00),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Color(0xffE0F1F0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Total \nEntries',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xff573240),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    '${specdata[0]['total']}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xffFF6F00),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: Color(0xffFCF6ED),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Available Entries',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xff573240),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    '${specdata[0]['available']}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-R',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xffFF6F00),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget BuildLoad() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: SpinKitRing(
          color: Color(0xffFCD4D0),
          size: 35,
          lineWidth: 5,
        ),
      ),
    );
  }
}
