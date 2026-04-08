// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import '../../modules/contact_form/contact_controller.dart';
//
// class ViewDetailsPageWeb extends StatefulWidget {
//   @override
//   State<ViewDetailsPageWeb> createState() => _ViewDetailsPageWebState();
// }
//
// class _ViewDetailsPageWebState extends State<ViewDetailsPageWeb> {
//   final contactController = Get.put(ContactController());
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Safe async fetch after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchContact();
//     });
//   }
//   void fetchContact() async {
//     await contactController.postFilterResults(
//       '', '', '', '','','',Api.userInfo.read('contactId1'), '','',context,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Contact Details")),
//       body: Row(
//         children: [
//           const AdminSideBar(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 900),
//                 child: GetBuilder<ContactController>(
//                   builder: (controller) {
//                     if (controller.senderContactLists.isEmpty) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     final contact = controller.senderContactLists.first;
//
//                     return Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 30,
//                                   backgroundColor: Colors.blue.shade100,
//                                   child: Icon(Icons.person, size: 30, color: Colors.blue),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       contact.Name ?? '',
//                                       style: const TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       contact.orgName ?? '',
//                                       style: TextStyle(color: Colors.grey.shade600),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//
//                             const SizedBox(height: 20),
//
//                             // Info Section
//                             Wrap(
//                               spacing: 40,
//                               runSpacing: 20,
//                               children: [
//                                 _infoTile(Icons.phone, "Mobile", contact.mobileNumber),
//                                 _infoTile(Icons.email, "Email", contact.email),
//                                 _infoTile(Icons.description, "Description", contact.materialDescription),
//                               ],
//                             ),
//
//                             const SizedBox(height: 30),
//
//                             // Image Gallery
//                             if (contact.contactImage != null && contact.contactImage!.isNotEmpty)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Images",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   SizedBox(
//                                     height: 120,
//                                     child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: contact.contactImage!.length,
//                                       itemBuilder: (_, index) {
//                                         final url = contact.contactImage![index];
//                                         return GestureDetector(
//                                           onTap: () {
//                                             Get.toNamed('/viewImagePage', arguments: {'url': url});
//                                           },
//                                           child: Container(
//                                             margin: const EdgeInsets.only(right: 12),
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.circular(12),
//                                               child: Image.network(
//                                                 url,
//                                                 width: 120,
//                                                 height: 120,
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Info Tile Widget
// Widget _infoTile(IconData icon, String title, String? value) {
//   return SizedBox(
//     width: 250,
//     child: Row(
//       children: [
//         Icon(icon, color: Colors.blue),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//               Text(value ?? '', style: TextStyle(color: Colors.grey.shade700)),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../../modules/contact_form/contact_controller.dart';

void showContactDetailsDialog(BuildContext context) {
  final contactController = Get.put(ContactController());

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      double size=MediaQuery.of(context).size.width;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder(
                future: contactController.postFilterResults('', '', '', '', '', '', Api.userInfo.read('contactId1'), '', '', context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  SizedBox(
                      height: size*0.35,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (contactController.filterContactLists.isEmpty) {
                    return  SizedBox(
                      height: size*0.15,
                      child: Center(child: Text('No contact found',style: AppTextStyles.caption(context),)),
                    );
                  }

                  final contact = contactController.filterContactLists.first;

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon:  Icon(Icons.close,color: Colors.redAccent,size: size*0.012,),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),

                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: size*0.023,
                              backgroundColor: Colors.white,
                              child:  Icon(Icons.person, size: size*0.014, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.Name ?? '',
                                  style: AppTextStyles.caption(context,)
                                ),
                                Text(
                                  contact.orgName ?? '',
                                    style: AppTextStyles.caption(context,)
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Info Section
                        Wrap(
                          spacing: 40,
                          runSpacing: 20,
                          children: [
                            _infoTile(Icons.phone, "Mobile", contact.mobileNumber),
                            _infoTile(Icons.email, "Email", contact.email),
                            _infoTile(Icons.description, "Description", contact.materialDescription),
                          ],
                        ),

                        const SizedBox(height: 20),

                        if (contact.contactImage != null && contact.contactImage!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                "Images",
                                  style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: contact.contactImage!.length,
                                  itemBuilder: (_, index) {
                                    final url = contact.contactImage![index];
                                    return GestureDetector(
                                      onTap: () {
                                        Get.toNamed('/viewImagePage', arguments: {'url': url});
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            url,
                                            width: size*0.05,
                                            height: size*0.013,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Info Tile Widget
Widget _infoTile(IconData icon, String title, String? value) {
  return SizedBox(
    width: 250,
    child: Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(value ?? '', style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ],
    ),
  );
}