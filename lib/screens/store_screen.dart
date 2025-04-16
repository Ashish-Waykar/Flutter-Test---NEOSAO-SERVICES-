import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/store_model.dart';
import '../providers/store_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}



class _StoreScreenState extends State<StoreScreen> {
  final mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).loadStores();
  }

  void _moveToStore(Store store) {
    mapController.move(LatLng(store.latitude, store.longitude), 13);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Consumer<StoreProvider>(
        builder: (context, provider, _) {
          final stores = provider.stores;
          final selected = provider.selectedStore;

          if (stores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Store> filteredStores = stores.where((store) {
            return store.storeLocation.toLowerCase().contains(_query.toLowerCase());
          }).toList();

          return Stack(
            children: [
              // Map
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.55,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: LatLng(stores[0].latitude, stores[0].longitude),
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: stores.map((store) {
                        final isSelected = selected?.code == store.code;
                        return Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(store.latitude, store.longitude),
                          builder: (_) => Icon(
                            Icons.location_pin,
                            color: isSelected ? Colors.blue : Colors.red,
                            size: isSelected ? 40 : 30,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Draggable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.45,
                minChildSize: 0.45,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            searchController: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _query = val;
                              });
                            },
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final store = filteredStores[index];
                              final isSelected = selected?.code == store.code;

                              return GestureDetector(
                                onTap: () {
                                  Provider.of<StoreProvider>(context, listen: false).selectStore(store);
                                  _moveToStore(store);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected ? Colors.orange : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    color: isSelected ? Colors.orange.shade50 : Colors.white,
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  store.storeLocation,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                              ),
                                              Text(
                                                '${store.distance.toStringAsFixed(2)} km',
                                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text('Away', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(store.storeAddress, style: const TextStyle(fontSize: 14)),
                                          const SizedBox(height: 6),
                                          const Text("Today, Thursday 12:00 PM–11:00 PM",
                                              style: TextStyle(fontSize: 13, color: Colors.grey))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredStores.length,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
        currentIndex: 2,
        onTap: (index) {
          // handle tab tap
        },
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final Function(String) onChanged;

  _StickyHeaderDelegate({
    required this.searchController,
    required this.onChanged,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.deepOrange,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search nearby stores...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => false;
}

