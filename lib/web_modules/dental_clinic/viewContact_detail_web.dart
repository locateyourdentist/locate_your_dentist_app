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