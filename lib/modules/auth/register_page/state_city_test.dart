// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
//
//
//
// class LocationScreen extends StatefulWidget {
//   const LocationScreen({super.key});
//
//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen> {
//   static const String baseUrl = "https://india-location-hub.in/api";
//   TextEditingController searchController = TextEditingController();
//
//   List states = [];
//   List districts = [];
//   List talukas = [];
//   List searchResults = [];
//
//   String? selectedState;
//   String? selectedDistrict;
//   String? selectedTaluka;
//
//   bool loading = false;
//
//   String? selectedVillage;
//   List<Map<String, dynamic>> villages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchStates();
//   }
//
//   Future<void> fetchStates() async {
//     try {
//       final res = await http.get(Uri.parse("$baseUrl/states"));
//       final data = json.decode(res.body);
//
//       // Access 'states' key, not 'data'
//       states = data['states'] ?? [];
//      print('states$data');
//       setState(() {}); // refresh UI
//     } catch (e) {
//       print("Error fetching states: $e");
//       setState(() {
//         states = [];
//       });
//     }
//   }
//
//   Future<void> fetchDistricts(String stateCode) async {
//     try {
//       final res = await http.get(
//         Uri.parse("$baseUrl/districts?state_code=$stateCode"),
//       );
//
//       final data = json.decode(res.body);
//
//       // Assign districts from 'districts' key
//       districts = data['districts'] ?? [];
//
//       // Clear selected district and taluka
//       selectedDistrict = null;
//       selectedTaluka = null;
//       talukas = [];
//
//       setState(() {});
//     } catch (e) {
//       print("Error fetching districts: $e");
//       districts = [];
//       talukas = [];
//       setState(() {});
//     }
//   }
//
//   Future<void> fetchTalukas(String districtCode) async {
//     try {
//       final res = await http.get(
//         Uri.parse("$baseUrl/talukas?district_code=$districtCode"),
//       );
//
//       final data = json.decode(res.body);
//
//       // Assign talukas from 'talukas' key
//       talukas = data['talukas'] ?? [];
//
//       selectedTaluka = null;
//
//       setState(() {});
//     } catch (e) {
//       print("Error fetching talukas: $e");
//       talukas = [];
//       selectedTaluka = null;
//       setState(() {});
//     }
//   }
//
//   Future<void> searchLocation(String query) async {
//     if (query.length < 3) {
//       setState(() {
//         searchResults = [];
//       });
//       return;
//     }
//
//     try {
//       final res = await http.get(Uri.parse("$baseUrl/search?q=$query"));
//       final data = json.decode(res.body);
//
//       // Adjust key based on your API response, e.g., 'results' or 'data'
//       searchResults = data['results'] ?? [];
//
//       setState(() {});
//     } catch (e) {
//       print("Error searching location: $e");
//       setState(() {
//         searchResults = [];
//       });
//     }
//   }
//   Future<void> fetchVillages(String talukaCode) async {
//     try {
//       final res = await http.get(Uri.parse("$baseUrl/villages?taluka_code=$talukaCode"));
//       final data = json.decode(res.body);
//
//       // Assuming API returns: { "villages": [ ... ] }
//       setState(() {
//         villages = List<Map<String, dynamic>>.from(data['villages'] ?? []);
//         selectedVillage = null; // reset selected village
//       });
//     } catch (e) {
//       print("Error fetching villages: $e");
//       setState(() {
//         villages = [];
//         selectedVillage = null;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("India Location Dropdown")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               /// STATE DROPDOWN
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: "Select State"),
//                 value: selectedState,
//                 items: states.map<DropdownMenuItem<String>>((s) {
//                   return DropdownMenuItem(
//                     value: s['code'],       // 'code' from API
//                     child: Text(s['name']), // 'name' from API
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   setState(() => selectedState = val);
//                   print('code$selectedState');
//                   fetchDistricts(val!); // fetch districts for selected state
//                 },
//               ),
//
//
//               const SizedBox(height: 16),
//
//               /// DISTRICT DROPDOWN
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: "Select District"),
//                 value: selectedDistrict,
//                 items: districts.map<DropdownMenuItem<String>>((d) {
//                   return DropdownMenuItem(
//                     value: d['code'].toString(), // convert to string
//                     child: Text(d['name']),
//                   );
//                 }).toList(),
//                 onChanged: districts.isEmpty
//                     ? null
//                     : (val) {
//                   setState(() => selectedDistrict = val);
//                   fetchTalukas(val!); // fetch talukas for this district
//                 },
//               ),
//
//
//               const SizedBox(height: 16),
//
//               /// TALUKA DROPDOWN
//               // DropdownButtonFormField<String>(
//               //   decoration: const InputDecoration(labelText: "Select Taluka"),
//               //   value: selectedTaluka,
//               //   items: talukas.map<DropdownMenuItem<String>>((t) {
//               //     return DropdownMenuItem(
//               //       value: t['code'].toString(),
//               //       child: Text(t['name']),
//               //     );
//               //   }).toList(),
//               //   onChanged: talukas.isEmpty
//               //       ? null
//               //       : (val) {
//               //     setState(() => selectedTaluka = val);
//               //     if (val != null) fetchVillages(val); // load villages
//               //   },
//               // ),
//               CustomDropdownField(
//                 hint: "Select Taluka",
//                 items: talukas.map((t) => t['name'].toString()).toList(),
//                 selectedValue: selectedTaluka,
//                 onChanged: (val) {
//                   setState(() {
//                     selectedTaluka = val;
//                     final taluka = talukas.firstWhere((t) => t['name'] == val);
//                     fetchVillages(taluka['code'].toString());
//                   });
//                 },
//               ),
//
//               CustomDropdownField(
//                 hint: "Select Village",
//                 items: villages.map((v) => v['name'].toString()).toList(),
//                 selectedValue: selectedVillage,
//                 onChanged: (val) {
//                   setState(() {
//                     selectedVillage = val;
//                   });
//                 },
//               ),
//
//               // DropdownButtonFormField<String>(
//               //   decoration: const InputDecoration(labelText: "Select Village"),
//               //   value: selectedVillage,
//               //   items: villages.map<DropdownMenuItem<String>>((v) {
//               //     return DropdownMenuItem(
//               //       value: v['code'].toString(),
//               //       child: Text(v['name']),
//               //     );
//               //   }).toList(),
//               //   onChanged: villages.isEmpty
//               //       ? null
//               //       : (val) {
//               //     setState(() => selectedVillage = val);
//               //   },
//               // ),
//
//               const SizedBox(height: 30),
//
//               // TextField(
//               //   controller: searchController, // add controller here
//               //   decoration: const InputDecoration(
//               //     labelText: "Search Village / Taluka / District",
//               //     border: OutlineInputBorder(),
//               //     suffixIcon: Icon(Icons.search),
//               //   ),
//               //   onChanged: (value) {
//               //     searchLocation(value);
//               //   },
//               // ),
//               //
//               //
//               // const SizedBox(height: 16),
//               //
//               // /// SEARCH RESULTS
//               // searchResults.isNotEmpty
//               //     ? ListView.builder(
//               //   shrinkWrap: true,
//               //   physics: const NeverScrollableScrollPhysics(),
//               //   itemCount: searchResults.length,
//               //   itemBuilder: (context, index) {
//               //     final item = searchResults[index];
//               //     return ListTile(
//               //       title: Text(item['name'] ?? ''),
//               //       subtitle: Text("${item['type'] ?? ''} • ${item['state_name'] ?? ''}"),
//               //     );
//               //   },
//               // )
//               //     : const Text("No results found"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const String baseUrl = "https://india-location-hub.in/api";

  List states = [];
  List districts = [];
  List talukas = [];
  List villages = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedTaluka;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  Future<void> fetchStates() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/states"));
      final data = json.decode(res.body);
      states = data['states'] ?? [];
      setState(() {});
    } catch (e) {
      print("Error fetching states: $e");
    }
  }

  Future<void> fetchDistricts(String stateCode) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/districts?state_code=$stateCode"));
      final data = json.decode(res.body);
      districts = data['districts'] ?? [];
      selectedDistrict = null;
      selectedTaluka = null;
      talukas = [];
      villages = [];
      selectedVillage = null;
      setState(() {});
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchTalukas(String districtCode) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/talukas?district_code=$districtCode"));
      final data = json.decode(res.body);
      talukas = data['talukas'] ?? [];
      selectedTaluka = null;
      villages = [];
      selectedVillage = null;
      setState(() {});
    } catch (e) {
      print("Error fetching talukas: $e");
    }
  }

  Future<void> fetchVillages(String talukaCode) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/villages?taluka_code=$talukaCode"));
      final data = json.decode(res.body);
      villages = List<Map<String, dynamic>>.from(data['villages'] ?? []);
      selectedVillage = null;
      setState(() {});
    } catch (e) {
      print("Error fetching villages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("India Location Dropdown")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// STATE DROPDOWN
              CustomDropdown<String>.search(
                hintText: "Select State",
                items: states.map((s) => s['name'].toString()).toList(),
                initialItem: selectedState,
                onChanged: (val) {
                  setState(() => selectedState = val);
                  if (val != null) {
                    final state = states.firstWhere((s) => s['name'] == val);
                    fetchDistricts(state['code'].toString());
                  }
                },
              ),

              const SizedBox(height: 16),

              /// DISTRICT DROPDOWN
              CustomDropdown<String>.search(
                hintText: "Select District",
                items: districts.map((d) => d['name'].toString()).toList(),
                initialItem: selectedDistrict,
                onChanged: (val) {
                  setState(() => selectedDistrict = val);
                  if (val != null) {
                    final district =
                    districts.firstWhere((d) => d['name'] == val);
                    fetchTalukas(district['code'].toString());
                  }
                },
              ),

              const SizedBox(height: 16),

              /// TALUKA SEARCHABLE DROPDOWN
              CustomDropdown<String>.search(
                hintText: "Select Taluka",
                items: talukas.map((t) => t['name'].toString()).toList(),
                initialItem: selectedTaluka,
                excludeSelected: false,
                onChanged: (val) {
                  setState(() => selectedTaluka = val);
                  if (val != null) {
                    final taluka =
                    talukas.firstWhere((t) => t['name'] == val);
                    fetchVillages(taluka['code'].toString());
                  }
                },
              ),

              const SizedBox(height: 16),

              /// VILLAGE SEARCHABLE DROPDOWN
              CustomDropdown<String>.search(
                hintText: "Select Village",
                items: villages.map((v) => v['name'].toString()).toList(),
                initialItem: selectedVillage,
                excludeSelected: false,
                onChanged: (val) {
                  setState(() => selectedVillage = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
