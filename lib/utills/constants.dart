
class AppConstants{
  static const baseUrl=
      //'https://lyd-backend-mjvx.onrender.com/';
      'http://192.168.31.117:3000/';
  static const razorPayKey='rzp_test_RzNhGYRP9d54Ca';
  static const webFireBaseVAPID_KEY='BIQ7RfHOZhssH1uXBZpuun3r6D7UhoHuAuqE4QjvpLolyo-E7_LDrYUnUOPYkMCh7VASKy2UWfyDg4DBNl7Khw8';
  static const appLogo='';
  static const appName='LOCATE YOUR DENTIST';
  static const developerCompanyName='Vorynto Private Limited';
  static const developerCompanyUrl='https://www.vorynto.com/';
  static const companyEmail='support@LYD.com';
  static const appDescription="LYD connects dental clinics, dental doctors, dental laboratories,dental shops, dental mechanics and job seekers in one platform.";
  //controller
  static const String userUrl='lyd/user/';
  static const String logoUrl='https://locate-your-dentist.s3.ap-south-1.amazonaws.com/appLogo/logoLYD.png';
  static const String serviceURL='lyd/services/';
  static const String jobUrl='lyd/jobs/';
  static const String notificationUrl='lyd/notifications/';
  static const String planUrl='lyd/plans/';
  static const String contactUrl='lyd/contacts/';
  static const String stateCityApiKey='7c7eaae3459e02fe3b1d4aefa52cb1c1f0b1beb35eb4cd05cd91d1c6ed958e8d';
  static const String stateUrl='get_indian_states';
  static const String districtUrl='districts/:state';
  static const String subDistrictUrl='subdistricts/:district';
  static const String villageUrl='villages/:subDistrict';


  //user
  static const String loginUrl='login_user';
  static const String switchAccountUrl='switch_user';
  static const String changePasswordUrl='change_password';
  static const String forgotPasswordUrl='forgot_password';
  static const String verifyOtpPasswordUrl='verify_password';
  static const String forgotChangePasswordUrl='forgotChangePassword';

  static const String saveFcmTokenUrl='save_fcm_token';
  static const String registerUrl='user_register';
  static const String createMail='create_email';
  static const String planEmailUrl='plan_email';
  static const String jobEmailUrl='job_email';
  static const String getProfileListUrl='get_user_details';
  static const String getBranchesUrl='get_all_branches';
  static const String getProfileById='get_user_byId';
  static const String getJobListAdmin='viewJobsAdminList';
  static const String getJobListJobSeekers='viewJobSeekerList';
  static const String getWebinarListJobSeekers='viewWebinarListJobseekers';
  static const String getJobSeekersAppliedLists='JobSeekers_apply_jobList';
  static const String getWebinarListAdmin='viewWebinarAdminList';
  static const String getJobById='getJobById';
  static const String getWebinarById='getWebinarById';
  static const String applyJobsJobSeekers='applyJobs_JobSeekers';
  static const String applyWebinarsJobSeekers='applyWebinar_JobSeekers';
  static const String appliedJobsListAdminUrl='getJobById_ApplicationList';
  static const String appliedWebinarsListAdminUrl='getWebinarById_ApplicationList';
  static const String postJobsAdminUrl='createJobAdmin';
  static const String postWebinarAdminUrl='createWebinarAdmin';
  static const String updateJobStatusUrl='update_status_Jobs';
  static const String updateJobApplicationStatusUrl='updateApplication_Status';
  static const String updateWebinarStatusUrl='updateWebinarStatus';
  static const String deactivateUserUrl='deactivate_user';
  static const String deleteFileUrl='delete_awsFile';
  static const String changeAppLogoUrl='change_appLogo';
  static const String getAppLogoUrl='get_appLogo';
  static const String getAllContacts='getAll_contact_details';

  //service
  static const String getServiceListUrl='get_service_list';
  static const String getServiceDetailsUrl='get_service_listById';
  static const String deactivateServiceUrl='deactivate_services';
  static const String createServiceUrl='create_service';

  //notification
  static const String getNotificationUrl='get_notification';
  static const String updateNotificationUrl='update_notification';
  static const String createNotificationUrl='create_notification';


  //plans
  static const String getCompanyDetailsUrl='getCompany_details';
  static const String addCompanyDetailsUrl='update_Company_details';
  static const String addContactDetailsStateWiseUrl='contact_details_state_wise';

  static const String addGstDetailsUrl='update_gst_details';
  static const String getGstDetailsUrl='getGst_details';
  static const String getInvoiceUrl='getInvoices';
  static const String getInvoiceByIdUrl='invoiceId';
  static const String getBasePlanUrl='get_PlanDetails';
  static const String getAddOnsPlanUrl='get_addOnsPlanDetails';
  static const String getJobsPlanUrl='get_jobPlanDetails';
  static const String getWebinarPlanUrl='get_webinarPlanDetails';
  static const String getPostImagePlanUrl='get_postImagePlanDetails';
  static const String getIncomeDetailsUrl='calculateIncome';
  static const String getExpenseDetailsUrl='get_expenses';
  static const String createBasePlanUrl='create_plan';
  static const String createAddOnsPlanUrl='create_addons_plan';
  static const String createJobPlanUrl='create_job_plan';
  static const String createJobCategoryUrl='create_job_category';
  static const String updateJobCategoryUrl='update_job_category';
  static const String getJobCategoryUrl='get_job_category';
  static const String deleteJobCategoryUrl='delete_job_category';
  static const String saveInvoiceUrl='createInvoice';
  static const String createWebinarPlanUrl='create_webinar_plan';
  static const String createPostImagePlanUrl='create_poster_image_plan';

  static const String checkPlanStatusUrl='check_planStatus';
  static const String jobPlanStatusUrl='getJobCountByUserId';
  static const String createUserBasePlanUrl='create_userPlan';
  static const String createUserAddOnsPlanUrl='create_addOnsUserPlan';
  static const String createUserJobPlanUrl='create_JobUserPlan';
  static const String createPostImageUserPlanUrl='create_posterImageUserPlan';
  static const String createWebinarUserPlanUrl='create_WebinarUserPlan';
  static const String addExpenseDetailsUrl='add_expenses';

  static const String uploadImagesUrl='uploadImages';
  static const String getUploadImagesUrl='get_upload_images';

 //Contact
  static const String postContactFormUrl='postContactDetails';
  static const String senderContactListUrl='senderContactLists';
  static const String receiverContactListUrl='receiverIdContactLists';
  static const String contactFilterSearchUrl='filterContactLists';


}