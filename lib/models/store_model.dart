class Store {
  final String code;
  final String storeLocation;
  final double latitude;
  final double longitude;
  final String storeAddress;
  final double distance;
  final bool isNearestStore;

  Store({
    required this.code,
    required this.storeLocation,
    required this.latitude,
    required this.longitude,
    required this.storeAddress,
    required this.distance,
    required this.isNearestStore,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      code: json['code'],
      storeLocation: json['storeLocation'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      storeAddress: json['storeAddress'],
      distance: json['distance'].toDouble(),
      isNearestStore: json['isNearestStore'] == 1,
    );
  }
}
