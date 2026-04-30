import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'color_code.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileImageWidget extends StatelessWidget {
  final double size;

  const ProfileImageWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = Api.userInfo.read('profileImage');
    const defaultImage = 'assets/images/lp3.jpg';

    final radius = size * 0.14;

    if (imagePath == null ||
        imagePath.toString().trim().isEmpty ||
        imagePath.toString().toLowerCase() == "null") {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage(defaultImage),
      );
    }
    final fullUrl = "${AppConstants.baseUrl}$imagePath";
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          fullUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              defaultImage,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

void confirmRemoveImage(BuildContext context, int index, VoidCallback onTap ) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Center(
        child: Text(
          "Remove Image",
          style: AppTextStyles.caption(fontWeight:FontWeight.bold ,context, color: AppColors.black),
        ),
      ),
      content: Text(
        "Are you sure you want to remove?",
        style: AppTextStyles.caption(context, color: AppColors.black),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text(
            "Cancel",
            style: AppTextStyles.caption(context, color: AppColors.black),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            "Remove",
            style: AppTextStyles.caption(context, color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
class CommonSearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSubmitted;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;

  const CommonSearchTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.isDense = true,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.caption(
          context,
          fontWeight: FontWeight.normal,
          color: AppColors.grey,
        ),
        border: InputBorder.none,
        isDense: isDense,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 8),
      ),
      style: AppTextStyles.caption(
        context,
        color: AppColors.black,
        fontWeight: FontWeight.normal,
      ),
      cursorColor: AppColors.primary,
      onSubmitted: onSubmitted,
    );
  }
}

String timeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) {
    return "just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minutes ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hours ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} days ago";
  } else if (diff.inDays < 30) {
    return "${(diff.inDays / 7).floor()} weeks ago";
  } else if (diff.inDays < 365) {
    return "${(diff.inDays / 30).floor()} months ago";
  } else {
    return "${(diff.inDays / 365).floor()} years ago";
  }
}
class CommonListTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const CommonListTile({
    super.key,
  required this.title,
  required this.onTap});

  @override
  Widget build(BuildContext context) {
    double s= MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: ListTile(title: Text(title,style: AppTextStyles.subtitle(context,color: AppColors.black
      ),),trailing: IconButton(onPressed:onTap,
          icon: Icon(Icons.arrow_forward_ios,color: AppColors.black,size:s*0.04,)),),
    );
  }
}
Future<void> sendEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    print('Could not launch $emailUri');
  }
}

String pageUserType(String userType) {
  String page;
  switch (userType) {
    case "Dental Clinic":
      page = "dentalClinicDashboard";
      break;
    case "Dental Shop":
      page = "mechanicDashboard";
      break;
    case "Dental Mechanic":
      page = "mechanicDashboard";
      break;
    case "Dental Lab":
      page = "mechanicDashboard";
      break;
    case "Dental Consultant":
      page = "mechanicDashboard";
      break;
    case "Job Seekers":
      page = "jobSeekerDashboard";
      break;
    case "admin":
      page = "superAdminDashboard";
      break;
    case "superAdmin":
      page = "superAdminDashboard";
      break;
    default:
      page = "";
  }
  return page;
}
String pageUserTypeWeb(String userType) {
  String page;
  switch (userType) {
    case "Dental Clinic":
      page = "dentalClinicDashboardWeb";
      break;
    case "Dental Shop":
      page = "dentalMechanicDashboardWebPage";
      break;
    case "Dental Mechanic":
      page = "dentalMechanicDashboardWebPage";
      break;
    case "Dental Lab":
      page = "dentalMechanicDashboardWebPage";
      break;
    case "Dental Consultant":
      page = "dentalClinicDashboardWeb";
      break;
    case "Job Seekers":
      page = "jobSeekerDashboardWeb";
      break;
    case "admin":
      page = "superAdminWebDashboard";
      break;
    case "superAdmin":
      page = "superAdminWebDashboard";
      break;
    default:
      page = "";
  }
  return page;
}
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "shortlisted":
      return Colors.green;
    case "rejected":
      return Colors.red;
    case "viewed":
      return Colors.orange;
    case "applied":
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
Color getRandomColor(String seed) {
  final colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  final hash = seed.hashCode;
  return colors[hash % colors.length];
}
String profilePage(String userType) {
  String page;
  switch (userType) {
    case "Dental Clinic":
      page = "clinicProfilePage";
      break;
    case "Dental Shop":
      page = "labProfilePage";
      break;
    case "Dental Mechanic":
      page = "labProfilePage";
      break;
    case "Dental Lab":
      page = "labProfilePage";
      break;
    case "Job Seekers":
      page = "jobSeekerViewProfilePage";
      break;
    case "Dental Consultant":
      page = "clinicProfilePage";
      break;
    case "admin":
      page = "patientDashboard";
      break;
    case "superAdmin":
      page = "superAdminDashboard";
      break;
    default:
      page = "patientDashboard";
  }
  return page;
}
String profilePageWeb(String userType) {
  String page;
  switch (userType) {
    case "Dental Clinic":
      page = "clinicProfileWebPage";
      break;
    case "Dental Shop":
      page = "clinicProfileWebPage";
      break;
    case "Dental Mechanic":
      page = "clinicProfileWebPage";
      break;
    case "Dental Lab":
      page = "clinicProfileWebPage";
      break;
    case "Job Seekers":
      page = "jobSeekerViewProfilePage";
      break;
    case "Dental Consultant":
      page = "clinicProfileWebPage";
      break;
    case "admin":
      page = "clinicProfileWebPage";
      break;
    case "superAdmin":
      page = "clinicProfileWebPage";
      break;
    default:
      page = "patientDashboard";
  }
  return page;
}
String imgUserType(String userType) {
  String page;
  switch (userType) {
    case "Dental Clinic":
      page = "assets/images/Dental_clinic.jpg";
      break;
    case "Dental Shop":
      page = "assets/images/dental_shop.jpg";
      break;
    case "Dental Mechanic":
      page = "assets/images/lp3.jpg";
      break;
    case "Dental Lab":
      page = "assets/images/Dental_Lab02.jpg";
      break;
    case "Dental Consultant":
      page = "assets/images/doctor1.jpg";
      break;
    case "Dental Consultant":
      page = "assets/images/hospital2.png";
      break;
    case "Dental Consultant":
      page = "assets/images/hospital2.png";
      break;
    default:
      page = "assets/images/hospital2.png";
  }
  return page;
}
Future<void> launchCall(String input) async {
  Uri uri;
  if (RegExp(r'^\+?\d+$').hasMatch(input)) {
    final phone = input.startsWith('+') ? input : '+$input';
    uri = Uri(scheme: 'tel', path: phone);
  } else if (!input.startsWith('http')) {
    uri = Uri.parse('https://$input');
  } else {
    uri = Uri.parse(input);
  }
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch $uri');
    }
  } catch (e) {
    debugPrint('Launch error: $e');
  }
}

 class CommonSettingContainer extends StatefulWidget {
  final String images;
  const CommonSettingContainer({
    super.key,
    required this.images,
  });
  @override
  State<CommonSettingContainer> createState() => _CommonSettingContainerState();
 }

 class _CommonSettingContainerState extends State<CommonSettingContainer> {
  @override
  Widget build(BuildContext context) {
    double s = MediaQuery.of(context).size.width;
    return Container(
      height: s * 0.13,
      width: s * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey, width: 0.3),
        color: AppColors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            widget.images,
            color: AppColors.black,fit: BoxFit.cover,
            //height: s * 1,width: s*0.0006,
          ),
        ),
      ),
    );
  }
}

class CommonContactContainer extends StatefulWidget {
  final IconData icons;
  final VoidCallback? onTap;
  final String? title;
  const CommonContactContainer({
    super.key,
    required this.icons,this.onTap,this.title,
  });
  @override
  State<CommonContactContainer> createState() => _CommonContactContainerState();
}
class _CommonContactContainerState extends State<CommonContactContainer> {
  @override
  Widget build(BuildContext context) {
    double s = MediaQuery.of(context).size.width;
    return Container(
      height:PlatformHelper.platform != "Web"? s * 0.25:s*0.04,
      width: PlatformHelper.platform != "Web"?s * 0.26:s*0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey, width: 0.3),
        color: AppColors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                     AppColors.primary,AppColors.secondary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: IconButton(
                 onPressed: widget.onTap,icon: Icon(widget.icons,color: AppColors.white,size:PlatformHelper.platform != "Web"? s * 0.08: s*0.012,),
                ),
              ),
            ),
            PlatformHelper.platform != "Web"?   SizedBox(height: s*0.02,):SizedBox(height: s*0.001,),
            Flexible(child: Text(widget.title.toString(),  overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,style: AppTextStyles.caption(context,color: AppColors.grey),))
          ],
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final String iconPath;
  final VoidCallback onTap;
  final double size;
  final String text;
  const AnimatedIconButton({
    super.key,
    required this.iconPath,
    required this.onTap,
    required this.text,
    this.size = 60,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration:  BoxDecoration(
                //shape: BoxShape.circle,
             borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                border: Border.all(
                  //color: getRandomColor(Jobs.orgName.toString()),
                    color: Colors.grey.shade300,
                    width: 1),
              ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black26,
                //     blurRadius: 8,
                //     offset: Offset(0, 1),
                //   ),
                // ],
              child: Center(
                child: Image.asset(
                  widget.iconPath,
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                ),
              ),
            ),
            SizedBox(height: widget.size*0.04,),
            Text(widget.text,style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}

