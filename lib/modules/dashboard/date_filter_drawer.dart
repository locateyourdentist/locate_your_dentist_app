// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// //
// class DateFilterPopup extends StatefulWidget {
//   final String selectedContactType;
//   const DateFilterPopup({Key? key, required this.selectedContactType}) : super(key: key);
//
//   @override
//   State<DateFilterPopup> createState() => _DateFilterPopupState();
// }
//
// class _DateFilterPopupState extends State<DateFilterPopup> {
//   DateTime? fromDate;
//   DateTime? toDate;
//   final contactController = Get.put(ContactController());
//
//   Future<void> _pickDate(bool isFrom) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//       });
//     }
//   }
//
//   Future<void> _pickDate1(bool isFrom) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate ?? DateTime.now(),
//       firstDate: fromDate ?? DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           fromDate = picked;
//         } else {
//           toDate = picked;
//         }
//       });
//     }
//   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     double width = MediaQuery.of(context).size.width ;
// //
// //     return Center(
// //       child: Material(
// //         color: Colors.transparent,
// //         child: Container(
// //           width: kIsWeb?width*0.15:0.85,
// //           padding: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(20),
// //             boxShadow: [
// //               const BoxShadow(
// //                 color: Colors.black26,
// //                 blurRadius: 10,
// //                 offset: Offset(0, 5),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const Text(
// //                 "Filter by Date",
// //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 20),
// //
// //               // From Date
// //               ListTile(
// //                 title: Text(
// //                   fromDate == null
// //                       ? "From Date"
// //                       : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",style: AppTextStyles.caption(context),
// //                 ),
// //                 trailing: Icon(Icons.calendar_today,color: AppColors.grey,size:!kIsWeb?width*0.05:width*0.011,),
// //                 onTap: () => _pickDate(true),
// //               ),
// //
// //               // To Date
// //               ListTile(
// //                 title: Text(
// //                   toDate == null
// //                       ? "To Date"
// //                       : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",style: AppTextStyles.caption(context),
// //                 ),
// //                 trailing: Icon(Icons.calendar_today,color: AppColors.grey,size:!kIsWeb?width*0.05:width*0.011,),
// //                 onTap: () => _pickDate1(false),
// //               ),
// //
// //               const SizedBox(height: 20),
// //
// //               Container(
// //                 width:kIsWeb?width*0.22:width*0.45,
// //                 height: kIsWeb?width*0.016:width*0.14 ,
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [AppColors.primary, AppColors.secondary],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.transparent,
// //                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                   onPressed: () async {
// //                     if (fromDate == null || toDate == null) return;
// //
// //                     final String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
// //                     final String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
// //
// //                     await contactController.getReceiverContactFormLists(
// //                       Api.userInfo.read('userId') ?? "",
// //                       formattedFromDate,
// //                       formattedToDate,
// //                       '',
// //                       context,
// //                     );
// //                     await contactController.getSenderContactFormLists(
// //                       Api.userInfo.read('userId') ?? "",
// //                       formattedFromDate,
// //                       formattedToDate,
// //                       '',
// //                       context,
// //                     );
// //
// //                     Navigator.pop(context);
// //                   },
// //                   child: Text(
// //                     "Apply Filter",
// //                     style: AppTextStyles.caption(context, color: AppColors.white),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery
//         .of(context)
//         .size
//         .width;
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         width: kIsWeb ? width * 0.15 : width * 0.85,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Filter by Date",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//
//             // From Date
//             ListTile(
//               title: Text(
//                 fromDate == null
//                     ? "From Date"
//                     : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
//                 style: AppTextStyles.caption(context),
//               ),
//               trailing: Icon(
//                 Icons.calendar_today,
//                 color: AppColors.grey,
//                 size: !kIsWeb ? width * 0.05 : width * 0.011,
//               ),
//               onTap: () => _pickDate(true),
//             ),
//
//             // To Date
//             ListTile(
//               title: Text(
//                 toDate == null
//                     ? "To Date"
//                     : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",
//                 style: AppTextStyles.caption(context),
//               ),
//               trailing: Icon(
//                 Icons.calendar_today,
//                 color: AppColors.grey,
//                 size: !kIsWeb ? width * 0.05 : width * 0.011,
//               ),
//               onTap: () => _pickDate1(false),
//             ),
//
//             const SizedBox(height: 20),
//
//             Container(
//               width: kIsWeb ? width * 0.22 : width * 0.45,
//               height: kIsWeb ? width * 0.016 : width * 0.14,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.primary, AppColors.secondary],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                 ),
//                 onPressed: () async {
//                   if (fromDate == null || toDate == null) return;
//
//                   final from = DateFormat('yyyy-MM-dd').format(fromDate!);
//                   final to = DateFormat('yyyy-MM-dd').format(toDate!);
//
//                   await contactController.getReceiverContactFormLists(
//                     Api.userInfo.read('userId') ?? "",
//                     from,
//                     to,
//                     '',
//                     context,
//                   );
//
//                   await contactController.getSenderContactFormLists(
//                     Api.userInfo.read('userId') ?? "",
//                     from,
//                     to,
//                     '',
//                     context,
//                   );
//
//                   Navigator.pop(context); // ✅ close dialog
//                 },
//                 child: Text(
//                   "Apply Filter",
//                   style: AppTextStyles.caption(context, color: AppColors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';


final ContactController controller = Get.put(ContactController());

// Call this wherever you want to show the popup
// void showDateFilterPopup(BuildContext context) {
//   double width = MediaQuery.of(context).size.width;
//     DateTime? fromDate;
//   DateTime? toDate;
//   Get.dialog(
//     Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       // child: Obx(() {
//
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           width: width * 0.85,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Filter by Date",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//
//               // From Date
//               ListTile(
//                 title: Text(
//                   fromDate == null
//                       ? "From Date"
//                       : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
//                 ),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) fromDate = picked;
//                 },
//               ),
//
//               // To Date
//               ListTile(
//                 title: Text(
//                   toDate == null
//                       ? "To Date"
//                       : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",
//                 ),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: fromDate ?? DateTime.now(),
//                     firstDate: fromDate?? DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) toDate = picked;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               ElevatedButton(
//                 onPressed: () async {
//                   if (fromDate == null || toDate == null) return;
//
//                   final from = DateFormat('yyyy-MM-dd').format(fromDate!);
//                   final to = DateFormat('yyyy-MM-dd').format(toDate!);
//
//                   Get.back(); // close popup
//
//                   // Call your API methods
//                   await controller.getReceiverContactFormLists(
//                     Api.userInfo.read('userId') ?? "",
//                     from,
//                     to,
//                     '',
//                     context,
//                   );
//                   await controller.getSenderContactFormLists(
//                     Api.userInfo.read('userId') ?? "",
//                     from,
//                     to,
//                     '',
//                     context,
//                   );
//                 },
//                 child: const Text("Apply Filter"),
//               ),
//             ],
//           ),
//         )
//       // }),
//     ),
//     barrierDismissible: true, // tap outside to close
//   );
// }
void showDateFilterPopup(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  DateTime? fromDate;
  DateTime? toDate;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            width: width * 0.15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filter by Date",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // From Date
                ListTile(
                  title: Text(
                    fromDate == null
                        ? "From Date"
                        : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        fromDate = picked; // rebuild dialog with new date
                      });
                    }
                  },
                ),

                // To Date
                ListTile(
                  title: Text(
                    toDate == null
                        ? "To Date"
                        : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: toDate ?? DateTime.now(),
                      firstDate: fromDate ?? DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        toDate = picked; // rebuild dialog
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (fromDate == null || toDate == null) return;

                    final from = DateFormat('yyyy-MM-dd').format(fromDate!);
                    final to = DateFormat('yyyy-MM-dd').format(toDate!);

                    Get.back(); // close popup

                    // Call your API methods
                    await controller.getReceiverContactFormLists(
                      Api.userInfo.read('userId') ?? "",
                      from,
                      to,
                      '',
                      context,
                    );
                    await controller.getSenderContactFormLists(
                      Api.userInfo.read('userId') ?? "",
                      from,
                      to,
                      '',
                      context,
                    );
                  },
                  child:  Text("Apply Filter",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: true,
  );
}