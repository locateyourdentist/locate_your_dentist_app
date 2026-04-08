class IncomeDashboardModel {
  final int total;
  final int posterIncome;
  final int basePlanIncome;
  final int addOnsIncome;
  final int jobIncome;
  final int webinarIncome;

  final int posterActiveUsers;
  final int basePlanActiveUsers;
  final int addOnsActiveUsers;
  final int jobActiveUsers;
  final int webinarActiveUsers;

  IncomeDashboardModel({
    required this.total,
    required this.posterIncome,
    required this.basePlanIncome,
    required this.addOnsIncome,
    required this.jobIncome,
    required this.webinarIncome,
    required this.posterActiveUsers,
    required this.basePlanActiveUsers,
    required this.addOnsActiveUsers,
    required this.jobActiveUsers,
    required this.webinarActiveUsers,
  });

  factory IncomeDashboardModel.fromJson(Map<String, dynamic> json) {

    int poster = json['posterIncome']?['income'] ?? 0;
    int basePlan = json['basePlanIncome']?['income'] ?? 0;
    int addOns = json['addOnsIncome']?['income'] ?? 0;
    int job = json['jobIncome']?['income'] ?? 0;
    int webinar = json['webinarIncome']?['income'] ?? 0;

    return IncomeDashboardModel(
      total: poster + basePlan + addOns + job + webinar,

      posterIncome: poster,
      basePlanIncome: basePlan,
      addOnsIncome: addOns,
      jobIncome: job,
      webinarIncome: webinar,

      posterActiveUsers: json['posterIncome']?['activeUsers'] ?? 0,
      basePlanActiveUsers: json['basePlanIncome']?['activeUsers'] ?? 0,
      addOnsActiveUsers: json['addOnsIncome']?['activeUsers'] ?? 0,
      jobActiveUsers: json['jobIncome']?['activeUsers'] ?? 0,
      webinarActiveUsers: json['webinarIncome']?['activeUsers'] ?? 0,
    );
  }
}

class ActiveUsers {
  final int poster;
  final int basePlan;
  final int addOns;
  final int job;
  final int webinar;

  ActiveUsers({
    required this.poster,
    required this.basePlan,
    required this.addOns,
    required this.job,
    required this.webinar,
  });

  factory ActiveUsers.fromJson(Map<String, dynamic> json) {
    return ActiveUsers(
      poster: json['posterActiveUsers'] ?? 0,
      basePlan: json['basePlanActiveUsers'] ?? 0,
      addOns: json['addOnsActiveUsers'] ?? 0,
      job: json['jobPlanActiveUsers'] ?? 0,
      webinar: json['webinarActiveUsers'] ?? 0,
    );
  }
}
