class Job {
  final String companyName;
  final String jobType;
  final String jobTitle;
  final String location;
  final String salary;
  final String appliedCount;

  Job({
    required this.companyName,
    required this.jobType,
    required this.jobTitle,
    required this.location,
    required this.salary,
    required this.appliedCount,
  });
}
class JobSeeker {
  final String name;
  final String state;
  final String district;
  final String city;
  final String experience;
  final String companyDetails;
  final String about;
  final String resumeUrl;

  JobSeeker({
    required this.name,
    required this.state,
    required this.district,
    required this.city,
    required this.experience,
    required this.companyDetails,
    required this.about,
    required this.resumeUrl,
  });
}
