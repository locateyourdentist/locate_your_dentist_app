import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';


final ContactController controller = Get.put(ContactController());
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