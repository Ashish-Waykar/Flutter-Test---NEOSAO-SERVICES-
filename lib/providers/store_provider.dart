import 'package:flutter/material.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  Store? _selectedStore;

  List<Store> get stores => _stores;
  Store? get selectedStore => _selectedStore;

  Future<void> loadStores() async {
    _stores = await StoreService.fetchStores();
    notifyListeners();
  }

  void selectStore(Store store) {
    _selectedStore = store;
    notifyListeners();
  }
}
