import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:cimo_mobile/ip.dart';

GetIp address = GetIp();

class FetchViolations {
  // ignore: non_constant_identifier_names
  List data = [];
  String? token = '';
  String? key = '';
  // ignore: non_constant_identifier_names
  FetchViolations({
    required this.token,
    required this.key,
  });
  Future<void> fetchviolation() async {
    Response response = await get(
        'http://${address.getip()}/cimo_desktop/app/fetch_viol.php?token=$token&&key=$key');
    data = jsonDecode(response.body);
    print(data);
  }
}
