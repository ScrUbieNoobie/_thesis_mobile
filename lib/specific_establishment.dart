import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:cimo_mobile/ip.dart';

GetIp address = GetIp();

class SpecificEstablishment {
  // ignore: non_constant_identifier_names
  String refid;
  List data = [];
  String? token = '';
  String? key = '';
  String? id = '';
  // ignore: non_constant_identifier_names
  SpecificEstablishment({
    required this.refid,
    required this.token,
    required this.key,
    required this.id,
  });
  Future<void> getSpec() async {
    Response response = await get(
        'http://${address.getip()}/cimo_desktop/app/general_api.php?eid=$refid&&token=$token&&key=$key&&id=$id');
    data = jsonDecode(response.body);
  }
}
