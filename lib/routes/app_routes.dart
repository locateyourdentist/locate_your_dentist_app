import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/password_page/change_password.dart';
import 'package:locate_your_dentist/modules/auth/password_page/forgot_password_page.dart';
import 'package:locate_your_dentist/modules/auth/password_page/verify_otp_page.dart';
import 'package:locate_your_dentist/modules/auth/register_page/add_branches.dart';
import 'package:locate_your_dentist/modules/auth/register_page/add_logoImage.dart';
import 'package:locate_your_dentist/modules/auth/register_page/register_page.dart';
import 'package:locate_your_dentist/modules/contact_form/post_contact_form.dart';
import 'package:locate_your_dentist/modules/contact_form/view_contactList_page.dart';
import 'package:locate_your_dentist/modules/dashboard/dental_clinic_dashboard.dart';
import 'package:locate_your_dentist/modules/dashboard/jobseekers_dashboard.dart';
import 'package:locate_your_dentist/modules/dashboard/mechanic_dashboard.dart';
import 'package:locate_your_dentist/modules/dashboard/patient_dashboard.dart';
import 'package:locate_your_dentist/modules/dashboard/post_images_admin.dart';
import 'package:locate_your_dentist/modules/dashboard/superAdmin.dart';
import 'package:locate_your_dentist/modules/dashboard/userType_list.dart';
import 'package:locate_your_dentist/modules/job_pages/add_job_category.dart';
import 'package:locate_your_dentist/modules/job_pages/applied_job_list.dart';
import 'package:locate_your_dentist/modules/job_pages/create_job_admin.dart';
import 'package:locate_your_dentist/modules/job_pages/view_job_webinar_posts.dart';
import 'package:locate_your_dentist/modules/job_pages/view_webinarApplicationLists.dart';
import 'package:locate_your_dentist/modules/job_pages/view_webinar_page.dart';
import 'package:locate_your_dentist/modules/job_pages/webinar_list_jobseekers.dart';
import 'package:locate_your_dentist/modules/landing_page/onboard_page.dart';
import 'package:locate_your_dentist/modules/notification_page/create_notification_admin.dart';
import 'package:locate_your_dentist/modules/notification_page/view_notifications.dart';
import 'package:locate_your_dentist/modules/plans/add_expense.dart';
import 'package:locate_your_dentist/modules/plans/add_gst_details.dart';
import 'package:locate_your_dentist/modules/plans/branch_list_page.dart';
import 'package:locate_your_dentist/modules/plans/company_details_add.dart';
import 'package:locate_your_dentist/modules/plans/expense_view_page.dart';
import 'package:locate_your_dentist/modules/plans/income_view_page_admin.dart';
import 'package:locate_your_dentist/modules/plans/payment_page.dart';
import 'package:locate_your_dentist/modules/plans/report_page.dart';
import 'package:locate_your_dentist/modules/plans/view_invoice_list.dart';
import 'package:locate_your_dentist/modules/plans/view_plan.dart';
import 'package:locate_your_dentist/modules/product_services/add-products.dart';
import 'package:locate_your_dentist/modules/product_services/view_product_services.dart';
import 'package:locate_your_dentist/modules/product_services/view_service_detailPage.dart';
import 'package:locate_your_dentist/modules/profiles/about_us_page.dart';
import 'package:locate_your_dentist/modules/profiles/clinic_edit_profile.dart';
import 'package:locate_your_dentist/modules/profiles/clinic_profile.dart';
import 'package:locate_your_dentist/modules/profiles/filter-resultPage.dart';
import 'package:locate_your_dentist/modules/profiles/job_detail_viewPage.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_edit_profile.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_filter_page.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
import 'package:locate_your_dentist/modules/profiles/lab_shop_profile.dart';
import 'package:locate_your_dentist/modules/profiles/setting_page.dart';
import 'package:locate_your_dentist/modules/profiles/view_image.dart';
import 'package:locate_your_dentist/modules/splash_screen/splash_screen.dart';
import 'package:locate_your_dentist/routes/app_pages.dart';
import 'package:locate_your_dentist/web_modules/auth_web/change_password_web.dart';
import 'package:locate_your_dentist/web_modules/auth_web/forgot_changePassword_web.dart';
import 'package:locate_your_dentist/web_modules/auth_web/forgot_password_web.dart';
import 'package:locate_your_dentist/web_modules/auth_web/register_web.dart';
import 'package:locate_your_dentist/web_modules/auth_web/verify_otp_page.dart';
import 'package:locate_your_dentist/web_modules/auth_web/web_login_page.dart';
import 'package:locate_your_dentist/web_modules/common/notification_page_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/landing_dashboard.dart';
import 'package:locate_your_dentist/web_modules/dashboard/super_Admin_dashboard.dart';
import 'package:locate_your_dentist/web_modules/dashboard/user_type_list_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/view_profile_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/add_services_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/clinic_profile_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/contact_list_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/create_job_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/dentallclinic_dashboard_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/edit_add_branch_details_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/my_invoice_list_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/my_servicesList_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/payment_page_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/applied_job_list_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/job_list_jobSeekers_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/job_seeker_dashboard_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/view_jobDetails_webdesign.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/view_jobWebinar_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/view_webinar_list_web.dart';
import 'package:locate_your_dentist/web_modules/job_seekers/view_webinar_webPage.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_app_logo_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_company_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_contact_details.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_expense_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_gst_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_jobCategory_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/create_notification_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/create_plan_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/scrollingAds_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/settings_page_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/view_plan_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/view_report_web.dart';
import '../modules/auth/login_screen/login_screen.dart';
import '../modules/plans/create_plan.dart';
import '../modules/profiles/clinic_web_view.dart';
import '../web_modules/common/aboutus_web.dart';
import '../web_modules/dental_mechanic_lab_shop/create_contact_web_page.dart';
import '../web_modules/dental_mechanic_lab_shop/dental_mechanic_dashboard.dart';

class AppPages {
  static final List<GetPage> page = [
  GetPage(
      name: AppRoutes.splashScreen,
      page:()=>const SplashScreen()
    ),
    GetPage(
    name: AppRoutes.loginPage,
    page: () => const LoginPage(),
     ),
    GetPage(
      name: AppRoutes.forgotPasswordWebScreen,
      page: () => const ForgotChangePasswordPage(),
    ),
    GetPage(
      name: AppRoutes.forgotPasswordEmailWeb,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.changePasswordWeb,
      page: () => const ChangePasswordWebPage(),
    ),
    GetPage(
      name: AppRoutes.notificationWebPage,
      page: () => const CreateNotificationWeb(),
    ),
    GetPage(
      name: AppRoutes.addGSTPageWeb,
      page: () => const AddGstDetailsWeb(),
    ),
    GetPage(
      name: AppRoutes.addLogoWeb,
      page: () => const ChangeAppLogoWeb(),
    ),
    GetPage(
      name: AppRoutes.addCompanyDetailsWeb,
      page: () => const CompanyFormWeb(),
    ),
    GetPage(
      name: AppRoutes.myServicesListWebPage,
      page: () => const ViewListServicesWebsite(),
    ),
    GetPage(
      name: AppRoutes.addServicesListWebPage,
      page: () => const AddProductWebPage(),
    ),
    GetPage(
      name: AppRoutes.contactFormListWebPage,
      page: () => const ViewContactListWeb(),
    ),
    GetPage(
      name: AppRoutes.viewProfilePageWeb,
      page: () => const ViewWebProfilePage(),
    ),
    GetPage(
      name: AppRoutes.viewJobWebinarWebPage,
      page: () => const ViewJobWebinarWebPage(),
    ),
    GetPage(
      name: AppRoutes.jobSeekerDashboardWeb,
      page: () => const JobSeekerDashboardWeb(),
    ),
    GetPage(
      name: AppRoutes.jobListJobSeekersWebPage,
      page: () => const JobSeekerFilterWeb(),
    ),
    GetPage(
      name: AppRoutes.appliedJobsListWeb,
      page: () => const AppliedJobListsWeb(),
    ),
    GetPage(
      name: AppRoutes.webinarListWebPage,
      page: () => const WebinarListWebPage(),
    ),
    GetPage(
      name: AppRoutes.viewNotificationWebPage,
      page: () => const ViewNotificationWeb(),
    ),
    GetPage(
      name: AppRoutes.createContactPageWeb,
      page: () => const ContactFormWebPage(),
    ),
    GetPage(
      name: AppRoutes.jobCategoryWeb,
      page: () => const JobCategoryScreenWeb(),
    ),
    GetPage(
      name: AppRoutes.aboutUsWebPage,
      page: () => const AboutUsWebPage(),
    ),
    GetPage(
      name: AppRoutes.scrollingAdsWebPage,
      page: () => const UploadImagesWeb(),
    ),
    GetPage(
      name: AppRoutes.createPlanPageWeb,
      page: () => const CreatePlanWeb(),
    ),
    GetPage(
      name: AppRoutes.viewPlanPageWeb,
      page: () => const ViewPlanWeb(),
    ),
    GetPage(
      name: AppRoutes.addBranchesWeb,
      page: () => const AddBranchesWeb(),
    ),
    GetPage(
      name: AppRoutes.clinicProfileWebPage,
      page: () => const ClinicProfileWeb(),
    ),
    GetPage(
      name: AppRoutes.reportPageWeb,
      page: () => const FinanceDashboardPage(),
    ),
    GetPage(
      name: AppRoutes.addExpenseWeb,
      page: () => const AddExpenseWeb(),
    ),
    GetPage(
      name: AppRoutes.dentalClinicDashboardWeb,
      page: () => const DentalClinicDashboardWebPage(),
    ),
    GetPage(
      name: AppRoutes.verifyPasswordWeb,
      page: () => const VerifyWebPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.registerPageWeb,
      page: () =>  RegisterWebPage(),
    ),
    GetPage(
      name: AppRoutes.registerPage,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.patientDashboard,
      page: () => const PatientDashboard(),
    ),
    GetPage(
      name: AppRoutes.clinicProfilePage,
      page: () => const ClinicProfile(),
    ),
    GetPage(
      name: AppRoutes.webViewProfilePage,
      page: () => const ClinicWeb(),
    ),
    GetPage(
        name: AppRoutes.clinicEditProfile,
        page:()=> const ClinicEditProfile()),
    GetPage(
        name: AppRoutes.settingPageMobile,
        page:()=>  const SettingsPageMobile()
    ),
    GetPage(
        name: AppRoutes.settingsWebPage,
        page:()=>      const SettingsPageWeb()
    ),
    GetPage(
        name: AppRoutes.labProfilePage,
        page:()=> const LabProfile()
    ),
    GetPage(
        name: AppRoutes.labContactForm,
        page: ()=> const ContactForm()
    ),
    GetPage(
        name: AppRoutes.viewImagePage,
        page: ()=> const ViewImage()
    ),
    GetPage(
        name: AppRoutes.createJobWebPage,
        page: ()=> const CreateJobPostWeb()
    ),
    GetPage(
        name: AppRoutes.myInvoiceListWebPage,
        page: ()=>  InvoiceListPageWeb()
    ),
    GetPage(
        name: AppRoutes.viewPlanPage,
        page:()=> const ViewPlan()
    ),
    GetPage(
        name: AppRoutes.createPlanPage,
        page: ()=>const CreatePlan()
    ),
    GetPage(
        name: AppRoutes.viewServiceList,
        page: ()=>const ViewListServices()
    ),
    GetPage(
        name: AppRoutes.notificationPage,
        page: ()=> const ViewNotification()
    ),
    GetPage(
        name: AppRoutes.filterResultPage,
        page:   ()=> const FilterResultPage()
    ),
    GetPage(
        name: AppRoutes.onBoardScreen,
        page:   ()=> const OnBoardPage()
    ),
    GetPage(
        name: AppRoutes.superAdminDashboard,
        page: ()=> const SuperAdminDashboardPage()
    ),
    GetPage(
        name: AppRoutes.userTypeListPage,
        page:()=> const userTypeList()
    ),
    GetPage(
        name: AppRoutes.dentalClinicDashboard,
        page: ()=> const DentalClinicDashboard()
    ),
    GetPage(
        name: AppRoutes.jobSeekerDashboard,
        page: ()=> const JobSeekerDashboard()
    ),
    GetPage(
        name: AppRoutes.jobViewProfilePage,
        page: ()=> const ViewJobPage()
    ),
    GetPage(
        name: AppRoutes.jobSeekerViewProfilePage,
        page: ()=> const JobSeekerProfilePage()
    ),
    GetPage(
        name: AppRoutes.filterPageJobSeekersPage,
        page: ()=> const JobSeekerFilter()
    ),
    GetPage(
        name: AppRoutes.appliedJobListPage,
        page: ()=> const AppliedJobLists()
    ),
    GetPage(
        name: AppRoutes.aboutUsPage,
        page: ()=> const AboutUsPage()
    ),
    GetPage(
        name: AppRoutes.createJobAdminPage,
        page: ()=> const CreateJobPost()
    ),
    GetPage(
        name: AppRoutes.jobSeekerEditProfilePage,
        page: ()=> const EditProfilePage()
    ),
    GetPage(
        name: AppRoutes.viewJobWebinarPage,
        page: ()=> const ViewJobWebinar()
    ),
    GetPage(
        name: AppRoutes.viewWebinarPage,
        page: ()=>  const WebinarViewPage()
    ),
    GetPage(
        name: AppRoutes.appliedJobsListAdmin,
        page: ()=>  const WebinarViewPage()
    ),
    GetPage(
        name: AppRoutes.webinarApplicantsList,
        page: ()=>  const ViewWebinarApplications()
    ),
    GetPage(
        name: AppRoutes.addJobCategoryPage,
        page: ()=>  const JobCategoryScreen()
    ),
    GetPage(
        name: AppRoutes.createServicesPage,
        page: ()=>  const AddProduct()
    ),
    GetPage(
        name: AppRoutes.viewServicePage,
        page: ()=>  const ServiceDetailPage()
    ),
    GetPage(
        name: AppRoutes.viewSenderContactList,
        page: ()=> const ViewContactList()
    ),
    GetPage(
        name: AppRoutes.mechanicDashboard,
        page: ()=> const MechanicDashboard()
    ),
    GetPage(
        name: AppRoutes.createPostImages,
        page: ()=> const UploadImages()
    ),
    GetPage(
        name: AppRoutes.createNotificationPage,
        page: ()=> const CreateNotificationAdmin()
    ),
    GetPage(
        name: AppRoutes.viewIncomePage,
        page: ()=> const IncomeDashboardPage()
    ),
    GetPage(
        name: AppRoutes.viewReportPage,
        page: ()=>  const ReportsDashboardPage()
    ),
    GetPage(
        name: AppRoutes.viewExpensePage,
        page: ()=> const ExpensePage()
    ),
    GetPage(
        name: AppRoutes.addExpensesPage,
        page: ()=> const AddExpense()
    ),
    GetPage(
        name: AppRoutes.paymentWebviewPage,
        page: ()=> const AddExpense()
    ),
    GetPage(
        name: AppRoutes.paymentPage,
        page: ()=>  CheckoutScreen()
    ),
    GetPage(
        name: AppRoutes.viewInvoiceListPage,
        page: ()=>  InvoiceListPage()
    ),
    GetPage(
        name: AppRoutes.paymentPageWeb,
        page: ()=>  CheckoutScreenWeb()
    ),
    GetPage(
        name: AppRoutes.changePasswordPage,
        page: ()=>  const ChangePassword()
    ),
    GetPage(
        name: AppRoutes.forgotPasswordPage,
        page: ()=>  const ForgotPassword()
    ),
    GetPage(
        name: AppRoutes.verifyPasswordPage,
        page: ()=>  const VerifyOtpPassword()
    ),
    GetPage(
        name: AppRoutes.forgotChangePasswordPage,
        page: ()=>   const ForgotChangePasswordPage()
    ),
    GetPage(
        name: AppRoutes.webLoginPage,
        page: ()=>   WebLoginPage()
    ),
    GetPage(
        name: AppRoutes.superAdminWebDashboard,
        page: ()=>   const AdminDashboard()
    ),
    GetPage(
        name: AppRoutes.userTypeListWeb,
        page: ()=>    ModernUserTable()
    ),
    GetPage(
        name: AppRoutes.changLogoImagePage,
        page: ()=>  const ChangeAppLogoImage()
    ),
    GetPage(
        name: AppRoutes.landingPage,
        page: ()=>  const LandingPage()
    ),
    GetPage(
        name: AppRoutes.viewJobDetailWebPage,
        page: ()=>  const ViewJobPageWeb()
    ),
    GetPage(
        name: AppRoutes.viewWebinarDetailWebPage,
        page: ()=>  const WebinarViewWebPage()
    ),
    GetPage(
        name: AppRoutes.dentalMechanicDashboardWebPage,
        page: ()=>  const DentalMechanicWebDashboard()
    ),
    GetPage(
        name: AppRoutes.addGSTPage,
        page: ()=>  const AddGstDetails()
    ),
    GetPage(
        name: AppRoutes.addCompanyPage,
        page: ()=>  const CompanyForm()
    ),
    GetPage(
        name: AppRoutes.addBranchesPage,
        page: ()=>  const AddBranches()
    ),
    GetPage(
        name: AppRoutes.branchListPage,
        page: ()=>  const BranchSelectionPage()
    ),
    GetPage(
        name: AppRoutes.viewWebinarListJobseekersPage,
        page: ()=>  WebinarCard()
    ),

  ];
}