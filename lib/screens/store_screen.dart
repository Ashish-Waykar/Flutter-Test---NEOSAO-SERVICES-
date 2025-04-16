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
  final ScrollController scrollController = ScrollController(); // Step 1

  @override
  void initState() {
    super.initState();
    Provider.of<StoreProvider>(context, listen: false).loadStores();
  }

  void _moveToStore(Store store) {
    mapController.move(LatLng(store.latitude, store.longitude), 13);
    scrollController.animateTo( // Step 3
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    scrollController.dispose(); // Always dispose controllers
    super.dispose();
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

          return SingleChildScrollView(
            controller: scrollController, // Step 2
            child: Column(
              children: [
                SizedBox(
                  height: 250,
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
                const SizedBox(height: 10),
                ...stores.map((store) {
                  final isSelected = store.code == selected?.code;

                  return GestureDetector(
                    onTap: () {
                      Provider.of<StoreProvider>(context, listen: false).selectStore(store);
                      _moveToStore(store); // Move + Scroll up
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${store.distance.toStringAsFixed(2)} km',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Away',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                store.storeAddress,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Today, Thursday 12:00 PM–11:00 PM",
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation logic here if needed
        },
      ),
    );
  }
}


// class _StoreScreenState extends State<StoreScreen> {
//   final mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<StoreProvider>(context, listen: false).loadStores();
//   }
//
//   void _moveToStore(Store store) {
//     mapController.move(LatLng(store.latitude, store.longitude), 13);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Store'),
//         backgroundColor: Colors.deepOrange,
//         centerTitle: true,
//       ),
//       body: Consumer<StoreProvider>(
//         builder: (context, provider, _) {
//           final stores = provider.stores;
//           final selected = provider.selectedStore;
//
//           if (stores.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 250,
//                   child: FlutterMap(
//                     mapController: mapController,
//                     options: MapOptions(
//                       center: LatLng(stores[0].latitude, stores[0].longitude),
//                       zoom: 12,
//                     ),
//                     children: [
//                       TileLayer(
//                         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                         subdomains: ['a', 'b', 'c'],
//                       ),
//                       MarkerLayer(
//                         markers: stores.map((store) {
//                           final isSelected = selected?.code == store.code;
//                           return Marker(
//                             width: 40,
//                             height: 40,
//                             point: LatLng(store.latitude, store.longitude),
//                             builder: (_) => Icon(
//                               Icons.location_pin,
//                               color: isSelected ? Colors.blue : Colors.red,
//                               size: isSelected ? 40 : 30,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ...stores.map((store) {
//                   final isSelected = store.code == selected?.code;
//
//                   return GestureDetector(
//                     onTap: () {
//                       Provider.of<StoreProvider>(context, listen: false).selectStore(store);
//                       _moveToStore(store);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(
//                             color: isSelected ? Colors.orange : Colors.transparent,
//                             width: 1.5,
//                           ),
//                         ),
//                         color: isSelected ? Colors.orange.shade50 : Colors.white,
//                         elevation: 2,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on, color: Colors.orange),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       store.storeLocation,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     '${store.distance.toStringAsFixed(2)} km',
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   const Text(
//                                     'Away',
//                                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 store.storeAddress,
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               const SizedBox(height: 6),
//                               const Text(
//                                 "Today, Thursday 12:00 PM–11:00 PM",
//                                 style: TextStyle(fontSize: 13, color: Colors.grey),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.deepOrange,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.fastfood),
//             label: 'Menu',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.store),
//             label: 'Store',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//         ],
//         currentIndex: 2,
//         onTap: (index) {
//           // Handle navigation logic here if needed
//         },
//       ),
//     );
//   }
// }
