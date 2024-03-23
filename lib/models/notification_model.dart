
class Notifications {
  List<NotificationModel>? notifications;

  Notifications.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <NotificationModel>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationModel.fromJson(v));
      });
    }
  }

}

class NotificationModel {
    int? notificationId;
    String? notificationTitle;
    String? notificationBody;
    String? notificationToken;
    String? notificationTime;
    int? memberId;
    int? userId;
    int? businessId;

    NotificationModel({
      required this.notificationId,
      required this.notificationTitle,
      required this.notificationBody,
      required this.notificationToken,
      required this.memberId,
      required this.userId,
      this.notificationTime,
      required this.businessId,
    });

    NotificationModel.fromJson(Map<String, dynamic> json) {
      notificationId = json['id'];
      notificationTitle = json['notification_title'];
      notificationBody = json['notification_body'];
      notificationToken = json['notification_token'];
      memberId = json['member_id'];
      userId = json['user_id'];
      businessId = json['business_id'];
      notificationTime = json['created_at'];
    }

  }

