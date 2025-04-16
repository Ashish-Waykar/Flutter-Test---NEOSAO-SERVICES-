import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_model.dart';

class StoreService {
  static Future<List<Store>> fetchStores() async {
    final response = await http.get(Uri.parse('https://atomicbrain.neosao.online/nearest-store'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => Store.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stores');
    }
  }
}
