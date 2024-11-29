import 'package:http/http.dart' as http;
import 'dart:convert';

fetchData(String val, String url) async{
  print("video sent");
  url = url+'?q=$val';
  http.Response response = await http.get(Uri.parse(url));
  print(response.body);
  var decodedVal = jsonDecode(response.body);
  print(decodedVal);
  print(decodedVal["present"]);

  return response.body;
}